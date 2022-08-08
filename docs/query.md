

# query

Simple SQL query builder. Helps to do 1 or multiple of these steps:
  1. adding computed columns
  2. filtering your data
  3. summarize columns across rows
  4. sorting your data

The order of operations in the SQL follows the list above.

New_Columns:
Takes a SQL expression and adds it to the table as a new column. i.e.: LEFT(ACCOUNT_ID, 5)

Filters:
Adds row filters to the WHERE part of the query

Summarize and Group_By:
Aggregate a column and group by another column

Order_By_Columns and Order_By_Direction:
Order the final table by one or more columns


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
