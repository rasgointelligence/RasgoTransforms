"""
Python Script to Publish all Transforms (for every DW) to S3
"""
import json
from typing import Dict

import boto3

import rasgotransforms


def camel_case(snake_str: str) -> str:
    """
    Convert a snake case string to camelcase
    """
    if not isinstance(snake_str, str):
        return snake_str
    components = snake_str.split('_')
    return f"{components[0]}{''.join(x.title() for x in components[1:])}"


def obj_to_camel(obj: any) -> any:
    # recursively convert the keys of a dict to camel case instead of snake.
    if isinstance(obj, list):
        return [obj_to_camel(i) if isinstance(i, (dict, list)) else i for i in obj]
    return {camel_case(k): obj_to_camel(v) if isinstance(v, (dict, list)) else v for k, v in obj.items()}


def get_some_transforms(dw_type: str):
    return [
        {**x.__dict__, 'dw_type': dw_type}
        for x in rasgotransforms.serve_rasgo_transform_templates(datawarehouse=dw_type)
    ]


def publish_transforms() -> None:
    """
    Build the json and push it to S3
    """
    # get ALL the transforms for each DW Type in the DataWarehouse Enum
    raw_transforms = [y for z in [get_some_transforms(x.name) for x in rasgotransforms.DataWarehouse] for y in z]
    # snake -> camel
    raw_transforms = obj_to_camel(raw_transforms)

    print(f'Publishing {len(raw_transforms)} Rasgo Transforms to S3')

    # upload to s3 with public read permissions
    s3 = boto3.client('s3')
    s3.put_object(
        ACL='public-read', Body=json.dumps(raw_transforms), Bucket='rasgo-transforms', Key='rasgo-transforms.json'
    )


if __name__ == "__main__":
    publish_transforms()
