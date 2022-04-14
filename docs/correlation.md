

# correlation

Run pairwise correlation on all numeric columns in the source_table

## Parameters

| Argument | Type |                Description                 | Is Optional |
| -------- | ---- | ------------------------------------------ | ----------- |
| none     | none | this transform does not take any arguments |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.correlation()
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/correlation/correlation.sql" %}

