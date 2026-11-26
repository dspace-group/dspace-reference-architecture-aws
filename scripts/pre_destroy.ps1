<#
.SYNOPSIS
    Removes obstacles that make "terraform destroy" fail or leave orphans behind.
.DESCRIPTION
    Reads the deployed resources from the Terraform state ("terraform show -json") and:
      pre-destroy (default):
        1. Kubernetes: scales down workloads, deletes LoadBalancer services, ingresses and PVCs
           (their AWS load balancers, ENIs and EBS volumes are not known to Terraform).
        2. Disables RDS deletion protection and removes a colliding "<id>-final-snapshot".
        3. Disables EC2 termination protection (license server).
        4. Empties all S3 buckets including object versions and delete markers.
    Without -Execute nothing is changed (dry run).
.PARAMETER Execute
    Perform the changes. Without it the script only prints what it would do.
.PARAMETER Profile
    AWS CLI profile.
.PARAMETER Region
    AWS region. Defaults to the region of the AWS CLI configuration.
.PARAMETER KubeConfig
    Path to the kubeconfig of the EKS cluster. Defaults to the current kubectl context.
.PARAMETER SkipKubernetes
    Skip the Kubernetes cleanup.
.PARAMETER SkipS3
    Skip emptying S3 buckets.
.EXAMPLE
    ./scripts/pre_destroy.ps1 -Profile myprofile
    ./scripts/pre_destroy.ps1 -Profile myprofile -Execute
    terraform destroy
#>
[CmdletBinding()]
param(
    [switch]$Execute,
    [string]$Profile,
    [string]$Region,
    [string]$KubeConfig,
    [switch]$SkipKubernetes,
    [switch]$SkipS3
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSScriptRoot -Parent

$awsArgs = @()
if ($Profile) { $awsArgs += @("--profile", $Profile) }
if ($Region) { $awsArgs += @("--region", $Region) }

function Write-Step($msg) { Write-Host "`n== $msg" -ForegroundColor Cyan }
function Write-Plan($msg) {
    if ($Execute) { Write-Host "  $msg" } else { Write-Host "  [dry-run] $msg" -ForegroundColor Yellow }
}

function Invoke-Aws {
    $out = & aws @awsArgs @args
    if ($LASTEXITCODE -ne 0) { throw "aws $($args -join ' ') failed" }
    return $out
}

function Invoke-AwsJson {
    $out = Invoke-Aws @args
    if (-not $out) { return $null }
    return ($out | Out-String | ConvertFrom-Json)
}

function Get-StateResources {
    Push-Location $repoRoot
    try {
        $json = terraform show -json
        if ($LASTEXITCODE -ne 0) { throw "terraform show failed" }
    }
    finally { Pop-Location }
    $state = $json | Out-String | ConvertFrom-Json
    $result = [System.Collections.Generic.List[object]]::new()
    function Walk($module, $acc) {
        if ($module.resources) { $acc.AddRange([object[]]$module.resources) }
        foreach ($child in $module.child_modules) { Walk $child $acc }
    }
    if ($state.values) { Walk $state.values.root_module $result }
    return $result.ToArray()
}

function Remove-S3BucketContent([string]$bucket) {
    Write-Plan "empty bucket s3://$bucket (objects, versions, delete markers)"
    if (-not $Execute) { return }
    & aws @awsArgs s3api head-bucket --bucket $bucket 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "  bucket $bucket not found, skipping"; return }

    foreach ($kind in @("Versions", "DeleteMarkers")) {
        while ($true) {
            $query = "{Objects: $kind[].{Key:Key,VersionId:VersionId}}"
            $batch = Invoke-AwsJson s3api list-object-versions --bucket $bucket --max-items 1000 --query $query
            if (-not $batch -or -not $batch.Objects) { break }
            $tmp = New-TemporaryFile
            try {
                @{ Objects = $batch.Objects; Quiet = $true } | ConvertTo-Json -Depth 5 -Compress | Set-Content $tmp -Encoding ascii
                Invoke-Aws s3api delete-objects --bucket $bucket --delete "file://$($tmp.FullName)" | Out-Null
            }
            finally { Remove-Item $tmp -Force }
        }
    }
}

function Invoke-KubernetesCleanup {
    Write-Step "Kubernetes: release load balancers and volumes"
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
        Write-Warning "kubectl not found, skipping Kubernetes cleanup"
        return
    }
    $kube = @()
    if ($KubeConfig) { $kube += @("--kubeconfig", $KubeConfig) }

    & kubectl @kube get ns 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Cluster not reachable, skipping Kubernetes cleanup. Orphaned load balancers/ENIs/EBS volumes may block VPC deletion."
        return
    }

    # kube-system hosts the load balancer controller, which must stay alive to remove the load balancers.
    Write-Plan "scale down Deployments/StatefulSets outside kube-system (releases PVCs)"
    $namespaces = (& kubectl @kube get ns -o jsonpath="{.items[*].metadata.name}") -split " " | Where-Object { $_ -ne "kube-system" }
    if ($Execute) {
        foreach ($ns in $namespaces) {
            & kubectl @kube scale deployment, statefulset --all --replicas=0 -n $ns 2>$null | Out-Null
        }
    }

    $services = (& kubectl @kube get svc -A -o json | ConvertFrom-Json).items | Where-Object { $_.spec.type -eq "LoadBalancer" }
    foreach ($s in $services) {
        Write-Plan "delete LoadBalancer service $($s.metadata.namespace)/$($s.metadata.name)"
        if ($Execute) { & kubectl @kube delete svc $s.metadata.name -n $s.metadata.namespace --wait=false | Out-Null }
    }

    Write-Plan "delete all Ingresses and PersistentVolumeClaims"
    if ($Execute) {
        & kubectl @kube delete ingress --all -A --wait=false 2>$null | Out-Null
        & kubectl @kube delete pvc --all -A --wait=false | Out-Null
    }

    if ($Execute) {
        Write-Host "  waiting up to 10 minutes for load balancers and PVs to be released"
        $deadline = (Get-Date).AddMinutes(10)
        do {
            $lb = @((& kubectl @kube get svc -A -o json | ConvertFrom-Json).items | Where-Object { $_.spec.type -eq "LoadBalancer" })
            $pv = @((& kubectl @kube get pv -o json | ConvertFrom-Json).items)
            if ($lb.Count -eq 0 -and $pv.Count -eq 0) { break }
            Start-Sleep -Seconds 15
        } while ((Get-Date) -lt $deadline)
        if ($lb.Count -or $pv.Count) {
            Write-Warning "Still present: $($lb.Count) LoadBalancer services, $($pv.Count) PersistentVolumes (retained PVs must be deleted manually)."
        }
    }
}

function Invoke-PreDestroy {
    Write-Step "Reading Terraform state"
    $resources = Get-StateResources
    $of = { param($type) @($resources | Where-Object { $_.type -eq $type }) }

    $dbs = & $of "aws_db_instance"
    $instances = & $of "aws_instance"
    $buckets = & $of "aws_s3_bucket"
    $clusters = & $of "aws_eks_cluster"

    if (-not $SkipKubernetes -and $clusters.Count -gt 0) { Invoke-KubernetesCleanup }

    Write-Step "RDS deletion protection"
    foreach ($db in $dbs) {
        $id = $db.values.identifier
        if ($db.values.deletion_protection) {
            Write-Plan "disable deletion protection of $id (also update Terraform state, see note below)"
            if ($Execute) {
                Invoke-Aws rds modify-db-instance --db-instance-identifier $id --no-deletion-protection --apply-immediately | Out-Null
            }
        }
        $snapshotId = $db.values.final_snapshot_identifier
        if ($snapshotId -and -not $db.values.skip_final_snapshot) {
            & aws @awsArgs rds describe-db-snapshots --db-snapshot-identifier $snapshotId 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Plan "delete existing snapshot $snapshotId (destroy would fail with SnapshotAlreadyExists)"
                if ($Execute) {
                    $answer = Read-Host "  Delete snapshot $snapshotId permanently? [y/N]"
                    if ($answer -eq "y") { Invoke-Aws rds delete-db-snapshot --db-snapshot-identifier $snapshotId | Out-Null }
                }
            }
        }
    }
    if ($dbs | Where-Object { $_.values.deletion_protection }) {
        Write-Host "  Note: terraform destroy re-reads the attribute on refresh; if it fails, run 'terraform apply -refresh-only' first." -ForegroundColor DarkGray
    }

    Write-Step "EC2 termination protection"
    foreach ($i in $instances) {
        Write-Plan "disable API termination protection of $($i.values.id)"
        if ($Execute) {
            Invoke-Aws ec2 modify-instance-attribute --instance-id $i.values.id --no-disable-api-termination | Out-Null
        }
    }
    if ($instances.Count) {
        Write-Host "  Note: Terraform also tracks disable_api_termination; run 'terraform apply -refresh-only' or '-target' apply with it set to false if destroy still refuses." -ForegroundColor DarkGray
    }

    if (-not $SkipS3) {
        Write-Step "S3 buckets"
        foreach ($b in $buckets) { Remove-S3BucketContent $b.values.bucket }
    }
}

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) { throw "AWS CLI not found." }
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) { throw "terraform not found." }
if (-not $Execute) { Write-Host "Dry run: no changes will be made. Use -Execute to apply." -ForegroundColor Yellow }

Invoke-PreDestroy
