import json
import subprocess
import yaml

from models.iam import Role, Policy
from models.security_group import SecurityGroup
from models.structure import Category, Service, ResourceType, Instance


def execute(cmd: str) -> dict:
    process = subprocess.run(cmd, capture_output=True, encoding="utf-8")
    if process.stderr:
        raise Exception(process.stderr)
    output = process.stdout
    return json.loads(output)


def index_value(arn: str):
    splits = arn.split(":")
    subtype = splits[5]
    try:
        subtype = subtype[0 : subtype.index("/")]
    except:
        pass
    if splits[2] == "s3":
        return "s3"
    return splits[2] + ":" + subtype


def get_security_groups(vpc_id: str) -> list[SecurityGroup]:
    security_groups = list()
    security_groups_query = execute(f"aws ec2 describe-security-groups --filters Name=vpc-id,Values={vpc_id}")
    for sg in security_groups_query["SecurityGroups"]:
        security_groups.append(SecurityGroup.from_data(sg))

    return security_groups


def get_roles_and_policies(cluster_id: str) -> tuple[list[Role], list[Policy]]:
    roles = execute("aws iam list-roles")
    role_objects: list[Role] = list()
    policies: list[Policy] = list()
    for role in roles["Roles"]:
        role_name = role["RoleName"]
        if (
            not role_name.startswith("AmazonSSM")
            and not role_name.startswith("AWSServiceRole")
            and not role_name.startswith("AWSReservedSSO")
        ):
            role_query = execute(f"aws iam get-role --role-name {role_name}")
            role_content: dict = role_query["Role"]
            if {"Key": "Cluster", "Value": cluster_id} in role_content.get("Tags", []):
                role_object = Role(role_name, role_content.get("Description", "").replace("\n", ""))
                attached_policies = execute(f"aws iam list-attached-role-policies --role-name {role_name}")
                role_policies = execute(f"aws iam list-role-policies --role-name {role_name}")

                for attached_policy in attached_policies["AttachedPolicies"]:
                    policy_query = execute(f"aws iam get-policy --policy-arn {attached_policy['PolicyArn']}")
                    policy = Policy(
                        attached_policy["PolicyName"],
                        policy_query["Policy"].get("Description", "").replace("\n", ""),
                        "AWS" if attached_policy["PolicyArn"].startswith("arn:aws:iam::aws:policy/") else "Customer",
                    )
                    policies.append(policy)
                    role_object.related_policies.append(policy)
                for policy_name in role_policies["PolicyNames"]:
                    policy = Policy(policy_name, None, None)
                    role_object.related_policies.append(policy)
                role_objects.append(role_object)

    return role_objects, policies


def get_roles_buffer(roles: list[Role]) -> str:
    buffer_roles = list()
    buffer_roles.append("| Role name | Description | Policies  |")
    buffer_roles.append("| --------- | ----------- | --------- |")
    for role in roles:
        buffer_roles.append(role.markdown())
    return "\n".join(buffer_roles)


def get_policies_buffer(policies: list[Policy]) -> str:
    buffer_policies = list()
    buffer_policies.append("| Policy name | Description | Managed By |")
    buffer_policies.append("| ----------- | ----------- | ---------- |")

    for policy in policies:
        buffer_policies.append(policy.markdown())
    return "\n".join(buffer_policies)


def get_security_group_buffer(security_groups: list[SecurityGroup]) -> str:
    header = "<tr><th>Group name</th><th>Group description</th><th>Direction</th><th>Protocol</th><th>Port range</th><th>Rule description</th></tr>"
    buffer = list()
    for group in security_groups:
        buffer.append(group.markdown_table())
    return f"<table>{header}\n\n{'\n'.join(buffer)}\n\n</table>"


def get_vpc_id(cluster_name: str) -> str:
    vpc_id = execute(
        f'aws ec2 describe-vpcs --filters "Name=tag:Name,Values={cluster_name}-vpc" --query "Vpcs[].VpcId"'
    )[0]
    return vpc_id


def get_categories(structure_file_path: str, cluster_name: str) -> list[Category]:
    with open(structure_file_path, "r") as structure_file:
        structure = yaml.safe_load(structure_file)
    arn_index = {}
    categories: list[Category] = list()

    for el in structure:
        category = Category.from_data(el)
        for service_el in el["services"]:
            service = Service(service_el["name"], category.path + "/" + service_el["icon"])
            for resource_el in service_el["resources"]:
                resource_ = ResourceType(
                    resource_el["name"],
                    category.path + "/" + resource_el.get("icon") if resource_el.get("icon", False) else None,
                    resource_el.get("arn", None),
                    resource_el.get("type", "normal"),
                    resource_el.get("source", None),
                    resource_el.get("arn_regex_name", None),
                    resource_el.get("arn_regex_id", None),
                )
                service.resources.append(resource_)
                arn_index.update({resource_.arn: resource_})
            category.services.append(service)
        categories.append(category)
    resources = execute(f"aws resourcegroupstaggingapi get-resources --tag-filters Key=Cluster,Values={cluster_name}")

    for resource in resources["ResourceTagMappingList"]:
        original_arn = resource["ResourceARN"]
        indexed_arn = index_value(original_arn)
        resource_ = arn_index.get(indexed_arn)
        if resource_:
            name = None
            for el in resource["Tags"]:
                key = el["Key"]
                value = el["Value"]
                if key == "Name":
                    name = value
            resource_.instances.append(Instance(name, original_arn))
    return categories


def populate_categories(
    categories: list[Category], security_groups: list[SecurityGroup], roles: list[Role], policies: list[Policy]
) -> list[str]:
    categories_buffer = list()
    for category in categories:
        categories_buffer.append(f"{category.get_title()}\n\n")
        for service in category.services:
            categories_buffer.append(f"{service.get_title()}\n\n")
            for resource in service.resources:
                if resource.type == "normal":
                    if resource.name == "Security group":
                        categories_buffer.append(
                            f"{resource.get_title()}\n\n{get_security_group_buffer(security_groups)}\n\n"
                        )
                    elif resource.name == "Roles":
                        categories_buffer.append(f"{resource.get_title()}\n\n{get_roles_buffer(roles)}\n\n")
                    elif resource.name == "Policies":
                        categories_buffer.append(f"{resource.get_title()}\n\n{get_policies_buffer(policies)}\n\n")
                    else:
                        resource_markdown = resource.markdown()
                        categories_buffer.append(resource_markdown)
                else:
                    with open(f"static/{resource.source}", "r", encoding="utf-8") as file:
                        requirement = file.read()
                    categories_buffer.append(f"{resource.get_title()}\n\n{requirement}\n")

    return categories_buffer
