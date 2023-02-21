

# one_hot_encode

One hot encode a column. Create a null value flag for the column if any of the values are NULL.

## Parameters

|     Name     |         Type         |                                         Description                                         | Is Optional |
| ------------ | -------------------- | ------------------------------------------------------------------------------------------- | ----------- |
| column       | column_or_expression | Column name to one-hot encode. Supports a calculated field via a valid SQL function.        |             |
| list_of_vals | string_list          | optional argument to override the dynamic lookup of all values in the target one-hot column | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.one_hot_encode(column='WEATHER_DESCRIPTION')
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/one_hot_encode/one_hot_encode.sql" %}

