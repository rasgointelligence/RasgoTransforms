"""
Utils for Documentation Generation from UDT Yaml Files
"""
import subprocess
from collections import defaultdict
from pathlib import Path
from typing import Dict

import yaml

TRANSFORM_TYPE_DIRS = ['column_operations', 'table_operations']


def load_all_yaml_files() -> Dict[str, Dict[str, Dict]]:
    """

    :return:
    """
    transform_yamls = defaultdict(dict)

    for transform_type_dir in TRANSFORM_TYPE_DIRS:
        transform_type_dir_path = _get_root_dir() / transform_type_dir

        # Get list of all transform of certain type
        transform_names = [x.name for x in transform_type_dir_path.rglob("*/**")]
        for transform_name in transform_names:

            try:
                # Try to load yaml file for transform
                transform_dir = transform_type_dir_path / transform_name
                transform_yaml_path = transform_dir / f"{transform_name}.yaml"
                transform_data = _read_yaml(transform_yaml_path)

                # If loaded successfully save in return dict
                transform_yamls[transform_type_dir][transform_name] = transform_data

            # TODO: Raise error msg/exception if YAML didn't exist
            except Exception as e:
                print(e)

    return transform_yamls


def get_table_values_from_transform(transform_args: Dict):
    pass


def _get_root_dir() -> Path:
    """
    Get and return the root directory POSIX PATH of this git repo
    """
    cmd = ["git", "rev-parse", "--show-toplevel"]
    root_dir_bytes = subprocess.check_output(cmd)
    root_dir_str = root_dir_bytes.decode('utf-8').strip()
    return Path(root_dir_str)


def _read_yaml(yaml_path: Path) -> Dict:
    """
    Read and load a YAML file into a dictionary
    """
    with open(yaml_path, "r") as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"Error Parsing YAML file at {yaml_path}"
                  f"\n\nError Msg: {e}")
