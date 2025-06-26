#$vaults = terraform output backup_vaults | ConvertFrom-Json
$profile = "wtc-dev"
# foreach ($vault in $vaults){
#   Write-Host "Deleting $vault"
#   $recoverypoints = aws backup list-recovery-points-by-backup-vault --profile $profile --backup-vault-name $vault | ConvertFrom-Json
#   foreach ($rp in $recoverypoints.RecoveryPoints){
#     aws backup delete-recovery-point --profile $profile --backup-vault-name $vault --recovery-point-arn $rp.RecoveryPointArn
#   }
#   foreach ($rp in $recoverypoints.RecoveryPoints){
#     Do
#     {
#       Start-Sleep -Seconds 10
#       aws backup describe-recovery-point --profile $profile --backup-vault-name $vault --recovery-point-arn $rp.RecoveryPointArn | ConvertFrom-Json
#     } while( $LASTEXITCODE -eq 0)
#   }
#   aws backup delete-backup-vault --profile $profile --backup-vault-name $vault
# }


# $databases = terraform output database_identifiers | ConvertFrom-Json
# foreach ($db in $databases){
#   Write-Host "Deleting database $db"
#   aws rds modify-db-instance --profile $profile --db-instance-identifier $db --no-deletion-protection
#   aws rds delete-db-instance --profile $profile --db-instance-identifier $db --skip-final-snapshot
# }

$buckets = terraform output s3_buckets | ConvertFrom-Json
foreach ($bucket in $buckets){
  aws s3 rb s3://$bucket --force --profile $profile
}

$buckets = terraform output s3_buckets | ConvertFrom-Json
foreach ($bucket in $buckets) {
    Write-Output "Deleting bucket: $bucket" 
    $deleteObjDict = @{}
    $deleteObj = New-Object System.Collections.ArrayList
    aws s3api list-object-versions --bucket $bucket --profile $profile --query '[Versions[*].{ Key:Key , VersionId:VersionId} , DeleteMarkers[*].{ Key:Key , VersionId:VersionId}]' --output json `
    | ConvertFrom-Json | ForEach-Object { $_ } | ForEach-Object { $deleteObj.add($_) } | Out-Null
    $n = [math]::Ceiling($deleteObj.Count / 100)
    for ($i = 0; $i -lt $n; $i++) {
        $deleteObjDict["Objects"] = $deleteObj[(0 + $i * 100)..(100 * ($i + 1))]
        $deleteObjDict["Objects"] = $deleteObjDict["Objects"] | Where-Object { $_ -ne $null }
        $deleteStuff = $deleteObjDict | ConvertTo-Json
        aws s3api delete-objects --bucket $bucket --profile $profile --delete $deleteStuff | Out-Null
    }
    aws s3 rb s3://$bucket --force --profile $aws_profile
    Write-Output "$bucket bucket deleted"
}