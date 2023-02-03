

# pivot_table

## Pivot table, powered by SQL.

### Required Inputs
- Values: a dictionary of the column with values you want to aggregate & the method of aggregation for your values

### Optional Inputs
- Rows: column(s) to group by down
- Columns: column(s) to pivot across
- Filters: filters to apply

### Notes
- Applies a hard limit of 500 distinct values in the 'columns' column


## Parameters

|  Name   |      Type       |                     Description                      | Is Optional |
| ------- | --------------- | ---------------------------------------------------- | ----------- |
| values  | column_agg_list | columns to aggregate                                 |             |
| rows    | column_list     | Columns to group by (column values will become rows) | True        |
| columns | column          | column with row values that will become columns      | True        |
| filters | filter_list     | Filters to apply to the table                        | True        |


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

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/pivot_table/snowflake/pivot_table.sql" %}

