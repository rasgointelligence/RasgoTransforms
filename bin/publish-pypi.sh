#!/bin/bash

set -e

if [ 1 != $# ]; then
    echo "usage: $0 index"
    echo "Index values: pypi pypitest"
    exit 1;
fi
PYPI_INDEX="$1"

# Remove old build artifacts
rm -rf dist/*

# Install dependencies
python -m pip install --upgrade pip
python -m pip install --upgrade setuptools build twine
python -m pip install -r rasgotransforms/requirements.txt

# Generate new artifacts
cd rasgotransforms
python -m build

# Upload artifacts to pypi
python -m twine upload --verbose  -r "$PYPI_INDEX" dist/*
