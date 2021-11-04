"""
Python Script to Create Transforms based off the YAML file definitions
within this Repo

Execute this script with a Installed selected Version of PyRasgo in your
python Environment
"""
import argparse

import pyrasgo

from python import utils


def create_transforms(rasgo_api_key: str, rasgo_domain: str) -> None:
    """
    Create all transforms in this repo with the supplied PyRasgo Api Key
    :param rasgo_api_key:
    :return:
    """
    # Set RASGO_DOMAIN Env
    utils.set_rasgo_domain_env(args.rasgo_domain)

    # Get all Rasgo Transform Names Available to User
    rasgo = pyrasgo.connect(rasgo_api_key)
    rasgo_transform_names = utils.get_all_rasgo_transform_names(rasgo)

    # Loop through all transform and respective data in this repo
    transform_yamls = utils.load_all_yaml_files()
    for transform_type, transform_type_yamls in transform_yamls.items():
        for transform_name, transform_yaml in transform_type_yamls.items():

            # If a Transform in Rasgo with that name already exists skip creating it
            if transform_name in rasgo_transform_names:
                print(f"Transform with name '{transform_name}' already exists in the "
                      f"Rasgo {rasgo_domain.upper()} environment; Skipping Creation.")

            # If name doesn't exist in Rasgo create the transform
            else:
                transform_source_code = utils.get_transform_source_code(
                    transform_type=transform_type,
                    transform_name=transform_name
                )
                transform_args = utils.parse_transform_args_from_yaml(transform_yaml)

                # Create Transform
                print(f"Creating '{transform_name}' transform in Rasgo {rasgo_domain.upper()} "
                      f"environment, with args {transform_args}")
                rasgo.create.transform(
                    name=transform_name,
                    source_code=transform_source_code,
                    arguments=transform_args
                )


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

    # Create all Transforms in this Repo
    create_transforms(rasgo_api_key, rasgo_domain)