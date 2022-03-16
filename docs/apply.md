

# apply

A transform that accepts a custom template to execute. Must use the sql template argument `source_table` to reference the Rasgo dataset which will serve as the base of any SELECT. Other templatized parameters must also be passed in as kwargs.

## Parameters

| Argument |  Type  |                Description                 | Is Optional |
| -------- | ------ | ------------------------------------------ | ----------- |
| sql      | custom | The custom SQL transform template to apply |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.apply(
  sql='SELECT * FROM {{ source_table }} WHERE {{ where_column }} = {{ where_value }}',
  where_column='NEW_LEADS_COL',
  where_value=100
)

ds2 = ds.apply(
  sql='SELECT * FROM {{ source_table }} WHERE COLUMNVALUE = I17'
)
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/table_transforms/apply/apply.sql" %}

