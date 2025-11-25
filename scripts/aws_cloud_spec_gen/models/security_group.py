from __future__ import annotations


class Rule:
    """! Class representation for AWS Security group rule."""

    def __init__(self, direction: str, description: str, port_range: str, protocol: str):
        self.direction = direction
        self.description = description
        self.port_range = port_range
        self.protocol = protocol

    @staticmethod
    def get_description(data: dict) -> str:
        """! Static method for parsing rule description from queried AWS Security group Rule.
        @param data (dict) https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html#output

        @return string
        """
        for range in data["IpRanges"]:
            if range.get("Description", "") != "":
                return range["Description"]
        return ""

    @staticmethod
    def get_port_range(data: dict) -> str:
        """! Static method for parsing rule's from and to port from queried AWS Security group rule.
        @param data (dict) https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html#output

        @return string
        """
        fromport = data.get("FromPort", False)
        toport = data.get("ToPort")
        if fromport:
            return f"{fromport} - {toport}" if fromport != toport else fromport
        return "All"

    @staticmethod
    def get_protocol(data: dict) -> str:
        """! Static method for parsing rule's protocol from queried AWS Security group rule.
        @param data (dict) https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html#output

        @return string
        """
        if data["IpProtocol"] == "-1":
            return "All"
        return data["IpProtocol"]

    @staticmethod
    def from_data(direction: str, data: dict) -> Rule:
        """! Static method for creating instance of this class from direction and data.
        @param direction (str) is the rule inbound or outbound
        @param data (dict) https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html#output

        @return models.security_group.Rule
        """
        return Rule(direction, Rule.get_description(data), Rule.get_port_range(data), Rule.get_protocol(data))

    def markdown_table(self) -> str:
        """! Method for getting Markdown representation of this object.

        @return str
        """
        return f"<td>{self.direction}</td><td>{self.protocol}</td><td>{self.port_range}</td><td>{self.description}</td>"


class SecurityGroup:
    """! Class representation of AWS Security group."""

    def __init__(self, name: str, description: str, rules: list[Rule]):
        self.name = name
        self.description = description
        self.rules: list[Rule] = rules

    def markdown_table(self) -> str:
        """! Method for getting Markdown representation of this object.

        @return str
        """
        rowspan = 1 if len(self.rules) == 0 else len(self.rules)
        markdown = f'<tr><td rowspan="{rowspan}">{self.name}</td><td rowspan="{rowspan}">{self.description}</td>'
        if len(self.rules) != 0:
            markdown = f"{markdown}{self.rules[0].markdown_table()}</tr>"
            for rule in self.rules[1:]:
                markdown += f"<tr>{rule.markdown_table()}</tr>"
        return markdown

    @staticmethod
    def get_name(data: dict) -> str:
        """! Static method for parsing Security group name from queried AWS Security group data.
        @param data (dict) https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html#output

        @return string
        """
        for tag in data.get("Tags", []):
            if tag["Key"] == "Name":
                return tag["Value"]
        return data["GroupName"]

    @staticmethod
    def from_data(data: dict) -> SecurityGroup:
        """! Static method for creating instance of this class from queried data.
        @param data (dict) https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html#output

        @return models.security_group.SecurityGroup
        """
        name = SecurityGroup.get_name(data)
        description = data.get("Description", "")
        inbound_rules = [Rule.from_data("inbound", rule_data) for rule_data in data["IpPermissions"]]
        outbound_rules = [Rule.from_data("outbound", rule_data) for rule_data in data["IpPermissionsEgress"]]
        rules = list([*inbound_rules, *outbound_rules])
        if len(rules) == 0:
            rules.append(Rule("-", "-", "-", "-"))
        return SecurityGroup(name, description, rules)
