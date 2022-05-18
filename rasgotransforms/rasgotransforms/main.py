"""
Functions to serve Rasgo Transform Templates
"""
import logging
import os
from enum import Enum
from collections import defaultdict
from pathlib import Path
from typing import Dict, List

import yaml

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


class DataWarehouse(Enum):
    """
    Supported Data Warehouses
    """

    BIGQUERY = "bigquery"
    SNOWFLAKE = "snowflake"
    POSTGRESQL = "postgresql"
    MYSQL = "mysql"
    REDSHIFT = "redshift"


class TransformTemplate:
    """
    Reference to a Rasgo transform template
    """

    def __init__(
        self, name: str, arguments: List[dict], source_code: str, description: str = None, tags: List[str] = None
    ):
        self.name = name
        self.arguments = arguments
        self.source_code = source_code
        self.description = description
        self.tags = tags

    def __repr__(self) -> str:
        arg_str = ", ".join(f'{arg.get("name")}: {arg.get("type")}' for arg in self.arguments)
        return f"RasgoTemplate: {self.name}({arg_str})"

    def define(self) -> str:
        """
        Return a pretty string definition of this Transform
        """
        pretty_string = (
            f"Transform: {self.name}"
            f"\nDescription: {self.description}"
            f"\nArguments: {self.arguments}"
            f"\nSourceCode: {self.source_code}"
        )
        return pretty_string


def serve_rasgo_transform_templates(datawarehouse: str) -> List[TransformTemplate]:
    """
    Return a list of Rasgo Transform Templates

    Optionally pass in a datawarehouse name to include templates
    specific to its SQL dialect
    """
    datawarehouse = _check_datawarehouse(datawarehouse)

    template_list = []
    transform_yamls = _load_all_yaml_files(datawarehouse)
    for transform_name, transform_yaml in transform_yamls.items():
        try:
            transform_source_code = _get_transform_source_code(
                transform_name=transform_name, datawarehouse=datawarehouse
            )
        except FileNotFoundError:
            # This allows for transforms for only specific data warehouses
            # otherwise raises without a base `sql` file in transform directory
            continue
        transform_args = _parse_transform_args_from_yaml(transform_yaml)
        template_list.append(
            TransformTemplate(
                name=transform_name,
                source_code=transform_source_code,
                arguments=transform_args,
                description=transform_yaml.get('description'),
                tags=transform_yaml.get('tags'),
            )
        )
    return template_list


def _check_datawarehouse(input_value: str) -> str:
    supported_dws = "'" + "', '".join([e.value for e in DataWarehouse]) + "'"
    try:
        DataWarehouse[input_value.upper()]
    except Exception:
        raise ValueError(f'datawarehouse parameter accepts values: {supported_dws}')
    return input_value.lower()


def _get_root_dir() -> Path:
    """
    Get and return the root directory absolute path of this git repo
    """
    return Path(os.path.dirname(__file__))


def _get_transform_source_code(transform_name: str, datawarehouse: str) -> str:
    """
    Return a transform's source code as a string
    """
    datawarehouse = _check_datawarehouse(datawarehouse)
    root_dir = _get_root_dir()
    source_code_path = root_dir / "transforms" / transform_name / f"{transform_name}.sql"
    source_code_override_path = root_dir / "transforms" / transform_name / datawarehouse / f"{transform_name}.sql"
    if source_code_override_path.exists():
        source_code_path = source_code_override_path
    with open(source_code_path) as fp:
        source_code = fp.read()
    return source_code


def _load_all_yaml_files(datawarehouse: str) -> Dict[str, Dict]:
    """
    Load and return all the yaml files in the dir <root>/<transform_type>_transforms
    """
    datawarehouse = _check_datawarehouse(datawarehouse)
    transform_yamls = defaultdict(dict)

    transform_dir_path = _get_root_dir() / "transforms"
    transform_names = [x.name for x in transform_dir_path.rglob("*/**")]
    for transform_name in transform_names:
        transform_yaml_path = transform_dir_path / transform_name / f"{transform_name}.yaml"

        try:
            transform_data = _read_yaml(transform_yaml_path)
            transform_yamls[transform_name] = transform_data
        except FileNotFoundError:
            continue

    return transform_yamls


def _parse_transform_args_from_yaml(transform_yaml: Dict) -> List[Dict[str, str]]:
    """
    From a loaded Transform Yaml File parse the
    Transform args in proper format, return the args
    in proper format for transform creation in PyRasgo
    """
    transform_args = []
    for arg_name, arg_meta_data in transform_yaml["arguments"].items():
        transform_args.append({**{"name": arg_name}, **arg_meta_data})
    return transform_args


def _read_yaml(yaml_path: Path) -> Dict:
    """
    Read and load a YAML file into a dictionary
    """
    with open(yaml_path, "r") as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as e:
            logger.error(f"Error Parsing YAML file at {yaml_path}" f"\n\nError Msg: {e}")
