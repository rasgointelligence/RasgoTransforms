

# simple_join

Simple join between two datasets that uses a 'USING' clause. Returns all columns from both tables in the result set.


## Parameters

|   Argument   |    Type     |                                               Description                                                | Is Optional |
| ------------ | ----------- | -------------------------------------------------------------------------------------------------------- | ----------- |
| join_table   | table       | Dataset object to join with the source_table                                                             |             |
| join_type    | join_type   | LEFT, RIGHT, or INNER                                                                                    |             |
| join_columns | column_list | Columns to join on. Can be one or more columns but must be named the same thing between the two objects. |             |


## Example

```python
d1 = rasgo.get.dataset(dataset_id)
d2 = rasgo.get.dataset(dataset_id_2)

ds2 = d1.transform.simple_join(
    join_table=d2,
    join_type='LEFT',
    join_columns=['DATE', 'FIPS']
)

ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/simple_join/simple_join.sql" %}

