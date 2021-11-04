"""
Utils for Documentation Generation from UDT Yaml Files
"""
import os
import subprocess
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Set

import yaml
from pyrasgo.rasgo import Rasgo

from . import constants

# ----------------------------------------------
#      Utils for Doc and Transform Creation
# ----------------------------------------------


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


# ----------------------------------------------
#          Utils for Transform Creation
# ----------------------------------------------


def set_rasgo_domain_env(rasgo_domain: str) -> None:
    """
    From Rasgo Domain/Enum Name, return the rasgo url for it

    :param rasgo_domain: 'local', 'staging', or 'production
    """
    rasgo_domains = constants.PyRasgoEnvironment._member_map_
    rasgo_domain_url = rasgo_domains[rasgo_domain.upper()].value
    os.environ["RASGO_DOMAIN"] = rasgo_domain_url


def get_all_rasgo_transform_names(rasgo: Rasgo) -> Set[str]:
    """
    Return a list of all transforms names available to
    the logged in Rasgo User
    """
    transform_in_rasgo = rasgo.get.transforms()
    return {t.name for t in transform_in_rasgo}


def get_transform_source_code(transform_type: str, transform_name: str) -> str:
    """
    From a transform name and type load and return it's source code as a string
    """
    root_dir = get_root_dir()
    source_code_path = root_dir / transform_type / transform_name / f"{transform_name}.sql"
    fp = open(source_code_path)
    source_code = fp.read()
    fp.close()
    return source_code


def parse_transform_args_from_yaml(transform_yaml: Dict) -> List[Dict[str, str]]:
    """
    From a loaded Transform Yaml File parse the
    Transform args in proper format, return the args
    in proper format for transform creation in PyRasgo
    """
    transform_args = []
    for arg_name, arg_meta_data in transform_yaml['arguments'].items():
        transform_args.append(
            {**{'name': arg_name}, **arg_meta_data}
        )
    return transform_args


def get_root_dir() -> Path:
    """
    Get and return the root directory absolute path of this git repo
    """
    cmd = ["git", "rev-parse", "--show-toplevel"]
    root_dir_bytes = subprocess.check_output(cmd)
    root_dir_str = root_dir_bytes.decode('utf-8').strip()
    return Path(root_dir_str)


# ----------------------------------------------
#          Utils for Docs Generation
# ----------------------------------------------


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


# ----------------------------------------------
#      Private Helper Funcs for this File
# ----------------------------------------------


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
