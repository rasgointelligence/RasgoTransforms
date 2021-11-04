"""
Module for converting text to different markdown elements
"""
from typing import Dict

from docs.docs_generation import utils
from pytablewriter import MarkdownTableWriter

GITHUB_REPO_URL = "https://github.com/rasgointelligence/RasgoUDTs/blob/main"


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
        headers=["Argument", "Type", "Description"],
        value_matrix=utils.get_table_values(transform_args),
        margin=1  # add a whitespace for both sides of each cell
    )
    markdown_table = writer.dumps()
    return markdown_table


def python_code(code: str) -> str:
    """
    Make a return a markdown python code snippet
    """
    return f"```python\n{code}\n```"""


def github_url(transform_type: str, transform_name: str) -> str:
    """
    Make and return the embedded url for transform source code
    """
    return '{% embed url="' + f"{GITHUB_REPO_URL}/{transform_type}/{transform_name}" \
                              f"/{transform_name}.sql" + '" %}'
