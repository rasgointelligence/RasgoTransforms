

# aggregate

Groups rows by the group_by items applying aggregations functions for the resulting group and selected columns

## Parameters

|     Name     |    Type     |                                                             Description                                                             | Is Optional |
| ------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| group_by     | column_list | Columns to group by                                                                                                                 |             |
| aggregations | agg_dict    | Aggregations to apply for other columns. Dict keys are column names, and values are a list of aggegations to apply for that column. |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.aggregate(group_by=['FIPS'], aggregations={
          'COL_1': ['SUM', 'AVG'],
          'COL_2': ['SUM', 'AVG']
      })
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/aggregate/snowflake/aggregate.sql" %}

