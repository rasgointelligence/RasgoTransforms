"""
Module for converting text to different markdown elements
"""
from contextlib import redirect_stdout
import io
from typing import Dict

from pytablewriter import MarkdownTableWriter
from maintenance.docs_generation import utils


GITHUB_REPO_URL = "https://github.com/rasgointelligence/RasgoUDTs/tree/main"


def h1(text: str) -> str:
    """
    Make and return text version of H1 Element
    """
    return f"# {text}"


def h2(text: str) -> str:
    """
    Make and return text version of H2 Element
    """
    return f"## {text}"


def text(text: str) -> str:
    """
    Make and return plain text element
    """
    return text


def table(transform_args: Dict) -> str:
    """
    From transform args dict, make and return a markdown table
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
    return f"```py\n{code}\n```"""


def github_url(transform_type: str, transform_name: str) -> str:
    """
    Make and return the embedded url for transform source code
    """
    return '{% embed url="' + f"{GITHUB_REPO_URL}/{transform_type}/{transform_name}" \
                              f"/{transform_name}.sql" + '" %}'
