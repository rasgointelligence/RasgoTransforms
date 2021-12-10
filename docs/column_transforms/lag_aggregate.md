

# lag_aggregate

Performs a temporal aggregate calculation from another dataset slicing aggregates by interval type and values.

## Parameters

|        Argument        |    Type     |                                                             Description                                                              |
| ---------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| base_source_id         | table       | dataset ID of the table to join with the source_table                                                                                |
| source_temporal_column | column      | The name of the column from the source data that specifies the source event timestamp                                                |
| base_temporal_column   | column      | The name of the column from the base event that specifies the base event timestamp.                                                  |
| source_join_columns    | column_list | Column/s to join from the source table. Col index in list must match with `base_join_colums` param.                                  |
| base_join_columns      | column_list | Column/s to join from the join table. Col index in list must match with `source_join_columns` param.                                 |
| aggregations           | agg_dict    | Aggregations to apply for source columns. Dict keys are column names, and values are a list of aggegations to apply for that column. |
| lag_period_type        | date_part   | Defines the period type for creating interval slices based on interval_values as supported by DB engine (DAY,MONTH,YEAR etc)         |
| lag_interval_list      | value_list  | A list of integers containing the lag slices in days.                                                                                |


## Example

```python
source = rasgo.read.source_data(source_id)
source.transform(
  transform_name="lag_aggregate",
  base_source_id=customer.id,
  source_temporal_column='ORDER_DATE',
  base_temporal_column='BASE_DATE',
  source_join_columns=['CUSTOMER_ID'],
  base_join_colums=['CUSTOMER_ID'],
  aggregations={
      'COL_1': ['SUM', 'AVG'],
      'COL_2': ['SUM', 'AVG']
  },
  lag_interval_type: 'DAY'
  lag_interval_list=[30,60,90]
).preview_sql()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/lag_aggregate/lag_aggregate.sql" %}

