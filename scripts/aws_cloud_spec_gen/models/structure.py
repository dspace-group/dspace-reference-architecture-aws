from __future__ import annotations
import re

PREFIX = "https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/"


class Instance:
    def __init__(self, name: str, arn: str):
        self.name = name
        self.arn = arn

    def get_entry(self, parent: ResourceType) -> str:
        if parent.arn_regex_name:
            self.name = re.search(parent.arn_regex_name, self.arn).group("name")
        if parent.arn_regex_id:
            self.name = re.search(parent.arn_regex_id, self.arn).group("id")

        return f"| {self.name} | tbd | tbd |"


class ResourceType:
    def __init__(self, name: str, icon: str, arn: str, type: str, source: str, arn_regex_name: str, arn_regex_id: str):
        self.name: str = name
        self.icon: str = icon
        self.arn = arn
        self.type = type
        self.source = source
        self.arn_regex_name: str = arn_regex_name
        self.arn_regex_id: str = arn_regex_id
        self.instances: list[Instance] = list()

    def get_title(self) -> str:
        title = f'### <a name="Resource_{self.name}"></a>'
        if self.icon != None:
            title = title + f"![{self.name}]({PREFIX}{self.icon})"
        title = f"{title} {self.name}"
        return title

    def markdown(self) -> str:
        if self.instances:
            entries = list()
            entries.append("| Name | Description | Mandatory |")
            entries.append("| - | - | - |")
            for instance in self.instances:
                entries.append(instance.get_entry(self))
            return f"{self.get_title()}\n\n{"\n".join(entries)}\n\n"
        return ""


class Service:
    def __init__(self, name: str, icon: str):
        self.name = name
        self.icon = icon
        self.resources: list[ResourceType] = list()

    def get_title(self) -> str:
        return f'## <a name="Service_{self.name}"></a> ![{self.name}]({PREFIX}{self.icon}) {self.name}'


class Category:
    def __init__(self, name: str, icon: str, path: str):
        self.name = name
        self.icon = icon
        self.path = path
        self.services: list[Service] = list()

    def get_title(self) -> str:
        return f'# <a name="Category_{self.name}"></a> ![{self.name}]({PREFIX}{self.icon}) {self.name}'

    @staticmethod
    def from_data(data: dict) -> Category:
        return Category(data["name"], data["path"] + "/" + data["icon"], data["path"])
