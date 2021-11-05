"""
Constants used for python code in the UDT Repo
"""
from enum import Enum


class PyRasgoEnvironment(Enum):
    """
    Different Environment for connecting PyRasgo to
    """
    PRODUCTION = "api.rasgoml.com"
    STAGING = "staging-rasgo-proxy.herokuapp.com"
    LOCAL = "localhost"


# Different Types of UDTs
# This var is used to find all transforms in the
# directory ./<transform_type>/...
TRANSFORM_TYPE_DIRS = [
    'column_transforms',
    'row_transforms',
    'table_transforms'
]

# Base Github Repo for UDT Jinja SQL Links
GITHUB_REPO_URL = "https://github.com/rasgointelligence/RasgoUDTs/blob/main"
