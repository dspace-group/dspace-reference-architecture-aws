"""
Description: Creates AWSCloudSpec.md document from AWS resources tagged with 'Cluster' tag of given value.
"""

import argparse
import os

from helpers import get_security_groups, get_roles_and_policies, get_vpc_id, get_categories, populate_categories


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cluster_name", required=True, help="Name of the deployed EKS cluster")
    parser.add_argument("--simphera_stage", required=True, help="Name of the SIMPHERA stage from '*.tfvars'")
    parser.add_argument("--simphera_instance", required=True, help="Name of the SIMPHERA instance from '*.tfvars'")
    parser.add_argument("--ivs_stage", required=True, help="Name of the IVS stage from '*.tfvars'")
    parser.add_argument("--gpu_driver", required=True, help="Selected driver version from ¨*.tfvars")

    return parser.parse_args()


def replace_with_generic(args, output: str) -> dict:
    to_replace = [
        {"name": args.cluster_name, "generic": "&lt;_cluster_name_&gt;"},
        {"name": args.ivs_stage, "generic": "&lt;_ivs_stage_&gt;"},
        {"name": args.simphera_stage, "generic": "&lt;_simphera_stage_&gt;"},
        {"name": args.simphera_instance, "generic": "&lt;_simphera_instance_name_&gt;"},
        {"name": os.environ["AWS_REGION"], "generic": "&lt;_aws_region_&gt;"},
        {"name": args.gpu_driver, "generic": "&lt;_gpu_driver_version_&gt;"},
    ]
    for element in to_replace:
        output = output.replace(element["name"], element["generic"])
    return output


def main(args):
    vpc_id = get_vpc_id(args.cluster_name)
    categories = get_categories("structure.yaml", args.cluster_name)
    security_groups = get_security_groups(vpc_id)
    roles, policies = get_roles_and_policies(args.cluster_name)
    output_buffer = populate_categories(categories, security_groups, roles, policies)
    output = replace_with_generic(args, "".join(output_buffer))
    with open("AWSCloudSpec.md", "w") as file:
        file.write(output)


if __name__ == "__main__":
    args = parse_args()
    main(args)
