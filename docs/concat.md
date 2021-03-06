

# concat

This function creates a new column that concatenates fixed values and columns in your dataset.

Pass in a list named "concat_list", containing the names of the columns and the static string values to concatenate, in order.


## Parameters

|       Name        |    Type    |                                   Description                                    | Is Optional |
| ----------------- | ---------- | -------------------------------------------------------------------------------- | ----------- |
| concat_list       | mixed_list | A list representing each new column to be created.                               |             |
| alias             | value      | Name for the new column created by the concatenation.                            | True        |
| overwrite_columns | boolean    | Optional: if true, the columns in 'concat_list' will be excluded from the output | True        |


## Example

```python
product = rasgo.get.dataset(75)
ds2 = product.concat(
  concat_list=['PRODUCTKEY', 'PRODUCTALTERNATEKEY', "' hybridkey'"],
  alias='Hybrid Key'
)

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/concat/concat.sql" %}

