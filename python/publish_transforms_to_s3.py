"""
Python Script to Publish all Transforms (for every DW) to S3
"""
import json

import boto3

import rasgotransforms


def to_camel_case(snake_str):
    components = snake_str.split('_')
    return f"{components[0]}{''.join(x.title() for x in components[1:])}"


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
    raw_transforms = [{to_camel_case(k): v for k, v in x.items()} for x in raw_transforms]
    print(f'Publishing {len(raw_transforms)} Rasgo Transforms to S3')

    # upload to s3 with public read permissions
    s3 = boto3.client('s3')
    s3.put_object(
        ACL='public-read', Body=json.dumps(raw_transforms), Bucket='rasgo-transforms', Key='rasgo-transforms.json'
    )


if __name__ == "__main__":
    publish_transforms()
