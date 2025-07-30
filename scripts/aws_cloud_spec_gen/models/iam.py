from __future__ import annotations

AWS_POLICY_DOC = "https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/"


class Role:
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.related_policies: list[Policy] = list()

    def get_related_policies_ref(self) -> str:
        policies_ref = ""
        for policy in self.related_policies:
            policies_ref += policy.get_list_item()
        return policies_ref

    def markdown(self) -> str:
        return f"| {self.name} | {self.description} | {self.get_related_policies_ref()} |"


class Policy:
    def __init__(self, name: str, description: str, managed_by: str):
        self.name = name
        self.description = description
        self.managed_by = managed_by

    def get_list_item(self) -> str:
        if self.description != None:
            return f"<li>[{self.name}](#{self.name})</li>"
        return f"<li>{self.name}</li>"

    def get_markdown_name(self) -> str:
        if self.managed_by == "AWS":
            return f"[{self.name}]({AWS_POLICY_DOC}{self.name})"
        return f"[{self.name}](./)"

    def markdown(self) -> str:
        name_ref = f'<a name="{self.name}"></a>' + self.get_markdown_name()
        return f"| {name_ref} | {self.description} | {self.managed_by} |"
