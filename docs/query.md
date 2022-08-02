

# query

Simple SQL query builder. Helps to do 1 or multiple of these steps:
  - selecting columns
  - adding computed columns
  - filtering your data
  - aggregating columns across rows
  - sorting your data

The order of operations in the SQL follows the list above.


## Parameters

|        Name        |      Type       |                                                                                                                                        Description                                                                                                                                         | Is Optional |
| ------------------ | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| new_columns        | math_list       | One or more SQL expressions to create new calculated columns in your table                                                                                                                                                                                                                 | True        |
| filters            | filter_list     | Remove rows using filter logic on one or more columns                                                                                                                                                                                                                                      | True        |
| summarize          | column_agg_list | Columns to summarize                                                                                                                                                                                                                                                                       | True        |
| group_by           | column_list     | One or more columns to group by A categorical column by which to pivot the calculated metrics. Including this argument will generate a new metric calculation for each distinct value in the group by column. If this column has more than 20 distinct values, the plot will not generate. | True        |
| order_by_columns   | column_list     | Pick one or more columns to order the data by                                                                                                                                                                                                                                              | True        |
| order_by_direction | sort_direction  | Order the data ASC or DESC                                                                                                                                                                                                                                                                 | True        |


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

