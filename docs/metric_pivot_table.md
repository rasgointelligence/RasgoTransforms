

# metric_pivot_table

## Pivot table for metrics, powered by SQL.

### Required Inputs
- Metrics: a dictionary of the metric values you want to aggregate

### Optional Inputs
- Rows: column(s) to group by down
- Columns: column(s) to pivot across
- Filters: filters to apply

### Notes
- Applies a hard limit of 500 distinct values in the 'columns' column


## Parameters

|        Name        |        Type        |                                                                                                                                            Description                                                                                                                                            | Is Optional |
| ------------------ | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| metrics            | comparison_list    | columns to aggregate                                                                                                                                                                                                                                                                              |             |
| rows               | dimension_list     | Dimensions to group by (column values will become rows)                                                                                                                                                                                                                                           | True        |
| columns            | dimension_list     | Dimensions with row values that will become columns                                                                                                                                                                                                                                               | True        |
| filters            | filter_list        | Filters to apply to the table                                                                                                                                                                                                                                                                     | True        |
| timeseries_options | timeseries_options | A dictionary containing the start and end dates as well as the time grain which will be used to create the datespine. Time grain options are ('day', 'week', 'month', 'year', 'quarter', and 'all') Example: {   "start_date": "2021-12-01",   "end_date": "2022-07-01",   "time_grain": "day" }  |             |


## Example

```python
ds2 = ds.pivot_table(
  rows=['DATE'],
  values={
      'CLOSE': ['SUM', 'AVG'],
      'OPEN': ['SUM', 'AVG']
  },
  columns='SYMBOL',
)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/metric_pivot_table/metric_pivot_table.sql" %}

