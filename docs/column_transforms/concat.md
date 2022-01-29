

# concat

This function creates a new column that concatenates fixed values and columns in your dataset.

Pass in a list named "concat_list", containing the names of the columns and the static string values to concatenate, in order.


## Parameters

|  Argument   |    Type    |                       Description                       | Is Optional |
| ----------- | ---------- | ------------------------------------------------------- | ----------- |
| concat_list | mixed_list | A list representing each new column to be created.      |             |
| name        | value      | A name for the new column created by the concatenation. | True        |


## Example

```python
product = rasgo.get.dataset(75)
ds2 = product.concat(
  concat_list=['PRODUCTKEY', 'PRODUCTALTERNATEKEY', "' hybridkey'"],
  name='Hybrid Key')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/concat/concat.sql" %}

