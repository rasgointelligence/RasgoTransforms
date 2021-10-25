

# rasgo_group_by

Groups rows by the group_by items applying aggregations functions for the resulting group and selected columns

## Parameters

|   Argument   |    Type     |                                                             Description                                                             |
| ------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| group_items  | column_list | Columns to group by                                                                                                                 |
| aggregations | agg_dict    | Aggregations to apply for other columns. Dict keys are column names, and values are a list of aggegations to apply for that column. |


## Example

```py
source.transform(
  transform_id=transform.id,
  group_items=['FIPS'],
  aggregations={
      'COL_1': ['SUM', 'AVG'],
      'COL_2': ['SUM', 'AVG']
  }
).preview_sql()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/table_operations/rasgo_group_by/rasgo_group_by.sql" %}

