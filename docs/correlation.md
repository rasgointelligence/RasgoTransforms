

# correlation

Run pairwise correlation on all numeric columns in the source_table

## Parameters

|      Name      | Type  |                              Description                               | Is Optional |
| -------------- | ----- | ---------------------------------------------------------------------- | ----------- |
| rows_to_sample | value | number of rows to sample from the table before calculating correlation | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.correlation()
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/correlation/correlation.sql" %}

