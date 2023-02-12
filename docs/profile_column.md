

# profile_column

## Analyze the distinct values in a column

### Required Inputs
- Column: the column you want to profile

### Notes
- Only supports profiling one column at a time


## Parameters

|    Name     |  Type  |          Description           | Is Optional |
| ----------- | ------ | ------------------------------ | ----------- |
| column_name | column | The column you want to profile |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds.profile_column(column_name = 'IMPORTANTCOLUMN')
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/profile_column/profile_column.sql" %}

