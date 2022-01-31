

# join

Join a dataset with another dataset, by matching on one or more columns between the two tables.

For columns that share the same name in both tables, the columns in the join_table will be aliased as "{join_table}_{columnname}".


## Parameters

|   Argument   |   Type    |                                                  Description                                                   | Is Optional |
| ------------ | --------- | -------------------------------------------------------------------------------------------------------------- | ----------- |
| join_table   | table     | Dataset object to join with the source dataset.                                                                |             |
| join_type    | join_type | LEFT, RIGHT, or INNER                                                                                          |             |
| join_columns | join_dict | Columns to use for the join. Keys are columns in the source_table and values are on columns in the join_table. |             |


## Example

```python
internet_sales = rasgo.get.dataset(74)
product = rasgo.get.dataset(75)

ds2 = internet_sales.join(
  join_table=product,
  join_columns={'PRODUCTKEY':'PRODUCTKEY'},
  join_type='LEFT')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/join/join.sql" %}

