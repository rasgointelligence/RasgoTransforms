"""
Python Script to Publish all Transforms based off the YAML file definitions
within this Repo

Execute this script with a Installed selected Version of PyRasgo in your
python Environment
"""
import argparse

import pyrasgo

import utils


def publish_transforms(rasgo_api_key: str, rasgo_domain: str) -> None:
    """
    Published all transforms in this repo

    If the transform name exists already in the db will update.
    If not will create a new one.

    Any other transforms in the DB, which aren't in this repo, will be deleted
    """
    # Set RASGO_DOMAIN Env
    utils.set_rasgo_domain_env(rasgo_domain)

    # Get all Rasgo Transform Names Available to User
    rasgo = pyrasgo.connect(rasgo_api_key)
    rasgo_transforms = utils.get_all_rasgo_transform_name_and_ids(rasgo)

    # Keep track of which transforms in repo were published
    published_transform_names = []

    # Loop through all transform and respective data in this repo
    transform_yamls = utils.load_all_yaml_files()
    for transform_type, transform_type_yamls in transform_yamls.items():
        for transform_name, transform_yaml in transform_type_yamls.items():
            transform_source_code = utils.get_transform_source_code(
                transform_type=transform_type,
                transform_name=transform_name
            )
            transform_args = utils.parse_transform_args_from_yaml(transform_yaml)

            # If a Transform in Rasgo with that name already exists update it
            if transform_name in rasgo_transforms.keys():
                print(f"Updating '{transform_name}' {transform_type} transform in "
                      f"Rasgo {rasgo_domain.upper()} environment, with args {transform_args}")
                rasgo.update.transform(
                    transform_id=rasgo_transforms[transform_name],
                    name=transform_name,
                    type=transform_type,
                    source_code=transform_source_code,
                    arguments=transform_args,
                    description=transform_yaml.get('description')
                )

            # If name doesn't exist in Rasgo create the transform
            else:
                print(f"Creating '{transform_name}' {transform_type} transform in "
                      f"Rasgo {rasgo_domain.upper()} environment, with args {transform_args}")
                rasgo.create.transform(
                    name=transform_name,
                    type=transform_type,
                    source_code=transform_source_code,
                    arguments=transform_args,
                    description=transform_yaml.get('description')
                )
            published_transform_names.append(transform_name)

    # Delete any transforms which are in db, but not in this repo
    transforms_to_delete = {
        transform_name: _id for transform_name, _id in rasgo_transforms.items()
        if transform_name not in published_transform_names
    }
    for transform_name, transform_id in transforms_to_delete.items():
        print(f"Deleting '{transform_name}' transform in Rasgo {rasgo_domain.upper()} environment")
        rasgo.delete.transform(transform_id)


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('pyrasgo-api-key', action='store')
    arg_parser.add_argument('-d', '--rasgo-domain',
                            action='store',
                            default='production',
                            choices=['local', 'staging', 'production'],
                            help="Rasgo Environment to connect to. Sets env var "
                                 "'RASGO_DOMAIN' for PyRasgo url dispatching "
                                 "(local, staging, or production).")

    # Get Rasgo API Key and Selected Domain
    args = arg_parser.parse_args()
    rasgo_api_key = getattr(args, 'pyrasgo-api-key')
    rasgo_domain = args.rasgo_domain

    # Publish all Transforms in this Repo
    publish_transforms(rasgo_api_key, rasgo_domain)
