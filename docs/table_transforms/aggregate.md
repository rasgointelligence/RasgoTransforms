

# aggregate

Groups rows by the group_by items applying aggregations functions for the resulting group and selected columns

## Parameters

|   Argument   |    Type     |                                                             Description                                                             |
| ------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| group_by     | column_list | Columns to group by                                                                                                                 |
| aggregations | agg_dict    | Aggregations to apply for other columns. Dict keys are assumed to be column names, and values are a list of aggegations to apply for that column. Optionally, the metric can be they key, if you specify agg_key='metric' as an optional argument. |
| agg_key      | string      | 'metric' will allow you to pass an agg_dict where the keys are an aggregation metric                                                |


## Example

```python
ds = rasgo.get.dataset(id)

  ds2 = ds.aggregate(group_by=['FIPS']
                    , aggregations={
                      'COL_1': ['SUM', 'AVG'],
                      'COL_2': ['SUM', 'AVG']
                      })
  ds2.preview()

# reversing the aggregations dict
  ds3 = ds.aggregate(group_by=['FIPS']
                    , aggregations={
                      'SUM': ['COL_1','COL_2'],
                      'AVG': ['COL_1','COL_2']
                      }
                    , agg_key='metric' 
                    )
  ds3.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/aggregate/aggregate.sql" %}

