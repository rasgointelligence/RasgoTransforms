

# rasgo_math

Create one or more new columns

## Parameters

| Argument |   Type    |                                         Description                                         |
| -------- | --------- | ------------------------------------------------------------------------------------------- |
| math_ops | math_list | List of math operations to generate new columns. Ex. ["<col_name> + 5", "<col_name> / 100"] |


## Example

```python
source = rasgo.get.data_source(id=363)

source.transform(
  transform_id=transform.id,
  filter_statements=[
    'MONTH * 12',
    'YEAR - 2000'
  ]
).preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_math/rasgo_math.sql" %}

