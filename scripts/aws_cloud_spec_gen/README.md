# AWS Cloud spec generation

This script is used for generating `AWSCloudSpec.md` of the current state of infrastructure.
Using AWS SDK cli, script is filtering AWS resources by the tag `Cluster` and generate `AWSCloudSpec.md`.

## Prerequisit
- reference architecture is deployed with everything enabled
    - `var.tags` must contain key `Cluster`, with the name of EKS cluster being deployed as a value
- since script is replacing custom names with generic strings your `*.tfvars` must not have same string set for certain resources, and neither of them cannot be substring of the other, e.g.:
    ```terraform
    infrastructurename = "CLUSTER_NAME"
    simpheraInstances = {
    "SIMPHERA_STAGE_NAME" : {
        "name" : "SIMPHERA_INSTANCE_NAME"
    }
    }
    ivsInstances = {
    "IVS_STAGE_NAME" : {}
    }
    ```
- use only one GPU driver version in tfvars
    ```terraform
    gpu_operator_config = {
        driver_versions = ["DRIVER_VERSION"]
    }
    ivsGpuDriverVersion = "DRIVER_VERSION"
    ```

## How to run a script
- move to directory `.\scripts\aws_cloud_spec_gen`
- install python requirements
    - pip install -r requirements.txt
- set environment variables for AWS credentials, `AWS_PROFILE` and `AWS_REGION`
- run script:
    ```powershell
    python main.py --cluster_id CLUSTER_NAME `
        --simphera_stage SIMPHERA_STAGE_NAME `
        --simphera_instance SIMPHERA_INSTANCE_NAME `
        --ivs_stage IVS_STAGE_NAME `
        --gpu_driver DRIVER_VERSION
    ```
- output is found at location `.\scripts\aws_cloud_spec_gen\AWSCloudSpec.md`

## Manual adaptation
- For each resource that has `Mandatory` column, specify is it mandatory or not
- Any missing resource description should be added
- In `Policies` section, for column `Policy name`, add missing links to the policy definition, either online or relative local link
