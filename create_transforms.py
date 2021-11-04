"""
Python Script to Create Transforms based off the YAML file definitions
within this Repo

Execute this script with a Installed selected Version of PyRasgo in your
python Environment
"""

# Different Types of UDTs
# This var is used to find all transforms in the
# directory ./<transform_type>/...
TRANSFORM_TYPE_DIRS = [
    'column_transforms',
    'row_transforms',
    'table_transforms'
]