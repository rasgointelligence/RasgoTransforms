# Remove old build artifacts
rm -rf dist/*

# Generate new artifacts
python setup.py sdist bdist_wheel

# Upload artifacts to pypi
python -m twine upload --verbose -r pypi dist/*
