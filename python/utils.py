"""
Utils for Documentation Generation from UDT Yaml Files
"""
import os
import subprocess
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Union, Tuple

import yaml
from pyrasgo.rasgo import Rasgo
from pyrasgo.schemas import Transform

import constants

# ----------------------------------------------
#      Utils for Doc and Transform Creation
# ----------------------------------------------


def get_root_dir() -> Path:
    """
    Get and return the root directory absolute path of this git repo
    """
    cmd = ["git", "rev-parse", "--show-toplevel"]
    root_dir_bytes = subprocess.check_output(cmd)
    root_dir_str = root_dir_bytes.decode('utf-8').strip()
    return Path(root_dir_str)


DOCS_DIR = get_root_dir() / 'docs'
TRANSFORMS_ROOT = get_root_dir() / 'rasgotransforms/rasgotransforms'


def load_all_yaml_files_as_dicts(path: Path) -> Dict[str, Dict]:
    """
    Load and return all the yaml files in the given path
    """
    yamls = defaultdict(dict)

    files = list(path.rglob("*.yml")) + list(path.rglob("*.yaml"))
    for file in files:
        # Try to load yaml file for transform
        # If loaded successfully save in return dict
        try:
            with open(file, "r") as stream:
                loaded = yaml.safe_load(stream)
                yamls[file.stem] = loaded
        except Exception as e:
            print(f"Can't read YAML file for transform {file.stem}\n" f"Error Msg: {e}\n")

    return yamls


def override_path_exists(transform_dir_path: Path, transform_name: str, dw_type: str) -> bool:
    """
    Returns true is an override file exists for this dw for this transform
    """
    transform_override_path = transform_dir_path / transform_name / dw_type / f"{transform_name}.sql"
    if transform_override_path.exists():
        return True
    return False


# ----------------------------------------------
#         Utils for Transform Publishing
# ----------------------------------------------


def set_rasgo_domain_env(rasgo_domain: str) -> None:
    """
    From Rasgo Domain/Enum Name, return the rasgo url for it

    :param rasgo_domain: 'local', 'staging', or 'production
    """
    rasgo_domains = constants.PyRasgoEnvironment._member_map_
    rasgo_domain_url = rasgo_domains[rasgo_domain.upper()].value
    os.environ["RASGO_DOMAIN"] = rasgo_domain_url


def get_all_rasgo_transform_keyed_by_name(rasgo: Rasgo) -> Dict[str, Transform]:
    """
    Return a Dict of all transforms keyed by names the respective
    transform as their value
    """
    transform_in_rasgo = rasgo.get.transforms()
    return {t.name: t for t in transform_in_rasgo}


def get_all_rasgo_community_transform_keyed_by_name_and_dw_type(rasgo: Rasgo) -> Dict[Tuple[str, str], Transform]:
    """
    Return a Dict of all transforms keyed by names the respective
    transform as their value
    """
    transform_in_rasgo = rasgo.get.community_transforms()
    return {(t.name, t.dw_type): t for t in transform_in_rasgo}


def transform_needs_versioning(
    transform: Transform,
    source_code: str,
    arguments: List[Dict[str, str]],
    description: str,
    tags: List[str],
    transform_type: str,
    context: Optional[Dict[str, Any]],
) -> bool:
    """
    Return true if any of the attributes for the transform has
    changed and it needs to be versioned

    This includes
      - description
      - transform type
      - source_code
      - all of the transform arguments and their attrs
      - set tags on the transform
      - transform type
      - context
    """
    transform_needs_versioning = (
        description != transform.description
        or source_code != transform.sourceCode
        or set(tags) != set(transform.tags)
        or _transform_args_have_changed(transform, arguments)
        or transform_type != transform.type
        or context != transform.context
    )
    return transform_needs_versioning


def get_transform_source_code_all_dws(transform_name: str) -> Dict[Tuple[str, str], str]:
    """
    From a transform name and type load and return its source code as a string
    """
    variants = {}
    transform_dir = TRANSFORMS_ROOT / "transforms"
    source_code_path = transform_dir / transform_name / f"{transform_name}.sql"
    if source_code_path.exists():
        variants[(transform_name, "UNSET")] = source_code_path.read_text(encoding="utf-8")

    other_dws = [
        path
        for path in (transform_dir / transform_name).glob("*")
        if path.is_dir() and (path / f"{transform_name}.sql").exists()
    ]

    for dw in other_dws:
        variants[(transform_name, dw.name.upper())] = (dw / f"{transform_name}.sql").read_text(encoding="utf-8")

    return variants


def parse_transform_args_from_yaml(transform_yaml: Dict) -> List[Dict[str, str]]:
    """
    From a loaded Transform Yaml File parse the
    Transform args in proper format, return the args
    in proper format for transform creation in PyRasgo
    """
    transform_args = []
    for arg_name, arg_meta_data in transform_yaml['arguments'].items():
        transform_args.append({**{'name': arg_name}, **arg_meta_data})
    return transform_args


def listify_tags(tags: Optional[Union[str, List[str]]]) -> List[str]:
    """
    Convert a dn return the the the possible values of a tag
    when parsed from a Yaml to a List of strings, so we can compare
    if the transform needs updating or not
    """
    if tags is None:
        return []
    elif isinstance(tags, str):
        return [tags]
    else:
        return tags


# ----------------------------------------------
#          Utils for Docs Generation
# ----------------------------------------------


def get_table_values(fields: List[str], table_dict: Dict[str, any]) -> List[List[str]]:
    """
    From a Transform Args Dict derived from YML file,
    generated a nested list of values to populate for the
    Markdown table describing each argument
    """
    table_data = []
    for name, item in table_dict.items():
        table_data.append([name] + [item.get(x, None) for x in fields])
    return table_data


# ----------------------------------------------
#      Private Helper Funcs for this File
# ----------------------------------------------


def _transform_args_have_changed(
    transform: Transform,
    arguments: List[Dict[str, str]],
) -> bool:
    """
    Return true if any of the transform arguments have changed
    false otherwise
    """
    # If number of args changed transform, transform needs versioning
    if len(transform.arguments) != len(arguments):
        return True
    # For each arg in yaml, see if anything changed compared to db
    for yaml_arg in arguments:
        db_args_w_name = [a for a in transform.arguments if a.name == yaml_arg['name']]

        # If a arg with this name isn't in db, transform needs versioning
        if not db_args_w_name:
            return True

        # Lastly check if any of the transform arg attrs have change
        # if so, transform needs versioning
        db_arg = db_args_w_name[0]
        if (
            db_arg.description != yaml_arg['description']
            or db_arg.is_optional != yaml_arg.get('is_optional', False)
            or db_arg.type != yaml_arg['type']
        ):
            return True

    # If nothing changed in transform arguments return False
    return False
