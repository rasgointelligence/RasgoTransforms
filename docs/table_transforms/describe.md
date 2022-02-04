

# describe

Describes the dataset using a consistent set of metrics, based on data type.
Numeric: DTYPE, COUNT, NULL_COUNT, UNIQUE_COUNT, MOST_FREQUENT, MEAN, STD_DEV, MIN, _25_PERCENTILE, _50_PERCENTILE, _75_PERCENTILE, MAX
Other: DTYPE, COUNT, NULL_COUNT, UNIQUE_COUNT, MOST_FREQUENT, MIN, MAX


## Parameters

| Argument | Type |                Description                 | Is Optional |
| -------- | ---- | ------------------------------------------ | ----------- |
| none     | none | this transform does not take any arguments |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds.describe().to_df()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/describe/describe.sql" %}

