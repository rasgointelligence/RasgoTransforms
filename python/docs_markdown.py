"""
Module for converting text to different markdown elements
"""
from typing import Dict, List


from pytablewriter import MarkdownTableWriter

import constants
import utils

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


def h3(string: str) -> str:
    """
    Make and return text version of H3 Element
    """
    return f"### {string}"

def bold(string: str) -> str:
    """
    bold that string
    """
    return f"**{string}**"

def table(headers: List[str], values: List[List]):
    writer = MarkdownTableWriter(
        headers=headers,
        value_matrix=values,
        margin=1,  # add a whitespace for both sides of each cell
    )
    return writer.dumps()


def python_code(code: str) -> str:
    """
    Make a return a markdown python code snippet
    """
    return f"```python\n{code}\n```"


def github_url(transform_type_dir_name: str, transform_name: str, dw_type_dir_name: str = None) -> str:
    """
    Make and return the embedded url for transform source code
    """
    dw_type_dir = f"/{dw_type_dir_name}" if dw_type_dir_name else ""
    return (
        f'{{% embed url="{constants.GITHUB_REPO_URL}/{transform_type_dir_name}'
        f'/{transform_name}{dw_type_dir}/{transform_name}.sql" %}}'
    )

def github_url(path: str) -> str:
    """
    Make and return the embedded url for transform source code
    """
    return (
        f'{{% embed url="{constants.GITHUB_REPO_URL}{path}" %}}'
    )