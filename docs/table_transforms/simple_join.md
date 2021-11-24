

# simple_join

Simple join between two datasets that uses a 'USING' clause. Returns all columns from both tables in the result set.


## Parameters

|   Argument   |    Type     |                                               Description                                                |
| ------------ | ----------- | -------------------------------------------------------------------------------------------------------- |
| join_table   | source      | source ID of the table to join with the source_table                                                     |
| join_type    | string      | LEFT, RIGHT, or INNER                                                                                    |
| join_columns | column_list | Columns to join on. Can be one or more columns but must be named the same thing between the two objects. |


## Example

```python
source = rasgo.read.source_data(source_id)

t1 = source.transform(
    transform_name='simple_join',
    join_table=mysource.id,
    join_type='LEFT',
    join_columns=['DATE', 'FIPS']
)

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/simple_join/simple_join.sql" %}

