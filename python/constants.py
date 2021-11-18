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


# Different Types of Transforms
# This var is used to find all transforms of a type in the
# directory <root>/<transform_type>_transforms/...
TRANSFORM_TYPES = [
    'column',
    'row',
    'table'
]

# Base Github Repo for UDT Jinja SQL Links
GITHUB_REPO_URL = "https://github.com/rasgointelligence/RasgoUDTs/blob/main"
