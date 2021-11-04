"""
Utils for Documentation Generation from UDT Yaml Files
"""
import subprocess
from collections import defaultdict
from pathlib import Path
from typing import Dict, List

import yaml

from . import constants


def load_all_yaml_files() -> Dict[str, Dict[str, Dict]]:
    """
    Load and return all the yaml files in the dirs <root>/<transform_type>>
    If new transform type/dir added be sure to add above in List TRANSFORM_TYPE_DIRS
    """
    transform_yamls = defaultdict(dict)

    for transform_type_dir in constants.TRANSFORM_TYPE_DIRS:
        transform_type_dir_path = get_root_dir() / transform_type_dir

        # Get list of all transform of certain type
        transform_names = [x.name for x in transform_type_dir_path.rglob("*/**")]
        for transform_name in transform_names:
            transform_dir = transform_type_dir_path / transform_name
            transform_yaml_path = transform_dir / f"{transform_name}.yaml"

            # Try to load yaml file for transform
            # If loaded successfully save in return dict
            try:
                transform_data = _read_yaml(transform_yaml_path)
                transform_yamls[transform_type_dir][transform_name] = transform_data
            except Exception as e:
                print(f"Can't read YAML file for transform {transform_name}\n"
                      f"Error Msg: {e}\n")

    return transform_yamls


def get_table_values(transform_args: Dict) -> List[List[str]]:
    """
    From a Transform Args Dict derived from YML file,
    generated a nested list of values to populate for the
    Markdown table describing each argument
    """
    all_data = []
    for arg_name, arg_info in transform_args.items():
        row_data = [
            arg_name,
            arg_info['type'],
            arg_info['description']
        ]
        all_data.append(row_data)
    return all_data


def get_root_dir() -> Path:
    """
    Get and return the root directory absolute path of this git repo
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
