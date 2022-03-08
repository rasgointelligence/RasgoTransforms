

# multi_join

Join n number of datasets with the 'base' dataset, using a consistent join_type and consistent list of join_columns across all joins.


## Parameters

|   Argument    |    Type     |                                                                           Description                                                                           | Is Optional |
| ------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| join_tables   | table_list  | Datasets to join with the source_table                                                                                                                          |             |
| join_type     | join_type   | Type of join to run against the base dataset (either LEFT, RIGHT, or INNER)                                                                                     |             |
| join_columns  | column_list | Columns to join on. Can be one or more columns but must be named the same thing between all datasets.                                                           |             |
| join_prefixes | value_list  | Pass a list of join_prefixes, one for each join_table in the join_tables list. These will be used to alias columns in the respective join_table after the join. |             |


## Example

```python
internet_sales = rasgo.get.dataset(74)
product = rasgo.get.dataset(75)
inventory = rasgo.get.dataset(65)

ds2 = internet_sales.multi_join(
  join_tables=[product.fqtn, inventory.fqtn],
  join_columns=['PRODUCTKEY'],
  join_type='LEFT',
  join_prefixes=['product', 'inventory'])

ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/table_transforms/multi_join/snowflake/multi_join.sql" %}

