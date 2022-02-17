

# one_hot_encode

One hot encode a column. Create a null value flag for the column if any of the values are NULL.

## Parameters

| Argument |  Type  |          Description          | Is Optional |
| -------- | ------ | ----------------------------- | ----------- |
| column   | column | Column name to one-hot encode |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.one_hot_encode(column='WEATHER_DESCRIPTION')
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/column_transforms/one_hot_encode/one_hot_encode.sql" %}

