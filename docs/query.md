

# query

## Construct a full SQL Query without writing it.

Supports any of these steps:
  1. adding new calculated columns
  2. filtering your data
  3. summarize columns across rows
  4. sorting your data

### Optional Inputs
- New Columns: Adds new columns to the base table via valid SQL functions
- Filters: filters to apply to the base table
- Summarize and Group_By: Aggregate a column and group by another column
- Order_By_Columns and Order_By_Direction:   Order the final table by one or more columns

### Notes
- If you choose to summarize any columns, then you must pick column(s) to group by as well


## Parameters

|        Name        |           Type            |                                     Description                                      | Is Optional |
| ------------------ | ------------------------- | ------------------------------------------------------------------------------------ | ----------- |
| new_columns        | calculated_column_list    | One or more SQL expressions to create new calculated columns in your table           | True        |
| filters            | filter_list               | Remove rows using filter logic on one or more columns                                | True        |
| summarize          | column_agg_list           | Columns to summarize                                                                 | True        |
| group_by           | column_or_expression_list | One or more columns to group by. Supports calculated fields via valid SQL functions. | True        |
| order_by_columns   | column_list               | Pick one or more columns to order the data by                                        | True        |
| order_by_direction | sort_direction            | Order the data ASC or DESC                                                           | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.query(
  new_columns=['LEFT(LEAD_SOURCE, 3)'],
  filters=[LEAD_SOURCE = 'Outbound'],
  summarize={
          'ID': ['COUNT'],
          'AMOUNT':['SUM']},
  group_by=['STAGE_NAME'],
  order_by_columns=['STAGE_NAME'],
  order_by_direction='ASC')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/query/snowflake/query.sql" %}

