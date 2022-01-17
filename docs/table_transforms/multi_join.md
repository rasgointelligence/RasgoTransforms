

# multi_join

Join n number of datasets with the 'base' dataset, using a consistent join_type and consistent list of join_columns across all joins.


## Parameters

|   Argument   |    Type     |                                              Description                                              | Is Optional |
| ------------ | ----------- | ----------------------------------------------------------------------------------------------------- | ----------- |
| join_tables  | table_list  | Datasets to join with the source_table                                                                |             |
| join_type    | join_type   | Type of join to run against the base dataset (either LEFT, RIGHT, or INNER)                           |             |
| join_columns | column_list | Columns to join on. Can be one or more columns but must be named the same thing between all datasets. |             |


## Example

```python
d1 = rasgo.get.dataset(dataset_id)
d2 = rasgo.get.dataset(dataset_id_2)
d3 = rasgo.get.dataset(dataset_id_3)

ds2 = d1.multi_join(
    join_tables=[d2, d3],
    join_type='LEFT',
    join_columns=['DATE', 'FIPS']
)

ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/multi_join/multi_join.sql" %}

