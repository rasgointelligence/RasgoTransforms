

# join

Join a dataset with another dataset, by matching on one or more columns between the two tables.

If you pass a join_prefix, all column names in the join table will be named "{join_prefix}_{columnname}".
If you don't pass a join_prefix, columns that share the same name in both tables will be only have the column from the base table included in the final output.


## Parameters

|   Argument   |   Type    |                                                  Description                                                   | Is Optional |
| ------------ | --------- | -------------------------------------------------------------------------------------------------------------- | ----------- |
| join_table   | table     | Dataset object to join with the source dataset.                                                                |             |
| join_type    | join_type | LEFT, RIGHT, or INNER                                                                                          |             |
| join_columns | join_dict | Columns to use for the join. Keys are columns in the source_table and values are on columns in the join_table. |             |
| join_prefix  | value     | Prefix all columns in the join_table with a string to differentiate them                                       | True        |


## Example

```python
internet_sales = rasgo.get.dataset(74)
product = rasgo.get.dataset(75)

ds2 = internet_sales.join(
  join_table=product,
  join_columns={'PRODUCTKEY':'PRODUCTKEY'},
  join_type='LEFT',
  join_prefix='product')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/table_transforms/join/join.sql" %}

