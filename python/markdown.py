"""
Module for converting text to different markdown elements
"""
from typing import Dict

from python import utils
from pytablewriter import MarkdownTableWriter

from . import constants


GITHUB_REPO_URL = "https://github.com/rasgointelligence/RasgoTransforms/blob/main"


def h1(string: str) -> str:
    """
    Make and return text version of H1 Element
    """
    return f"# {string}"


def h2(string: str) -> str:
    """
    Make and return text version of H2 Element
    """
    return f"## {string}"


def text(string: str) -> str:
    """
    Make and return plain text element
    """
    return string


def table(transform_args: Dict) -> str:
    """
    From transform args dict, make and return a markdown table of
    transform args descriptions
    """
    writer = MarkdownTableWriter(
        headers=["Argument", "Type", "Description", "Is Optional"],
        value_matrix=utils.get_table_values(transform_args),
        margin=1,  # add a whitespace for both sides of each cell
    )
    markdown_table = writer.dumps()
    return markdown_table


def python_code(code: str) -> str:
    """
    Make a return a markdown python code snippet
    """
    return f"```python\n{code}\n```" ""


def github_url(transform_type_dir_name: str, transform_name: str, dw_type_dir_name: str = None) -> str:
    """
    Make and return the embedded url for transform source code
    """
    dw_type_dir = f"/{dw_type_dir_name}" if dw_type_dir_name else ""
    return (
        f'{{% embed url="{constants.GITHUB_REPO_URL}/{transform_type_dir_name}'
        f'/{transform_name}{dw_type_dir}/{transform_name}.sql" %}}'
    )
