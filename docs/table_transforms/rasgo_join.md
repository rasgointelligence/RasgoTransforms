

# rasgo_join

Join a source table with another join table based on certain join keys between table. **NOTE**: If columns in the Join table are the same from the source table, the outputted column name from the join table will prefixxed with its table name. 

## Parameters

|    Argument    |    Type     |                                           Description                                            |
| -------------- | ----------- | ------------------------------------------------------------------------------------------------ |
| join_table_id  | source      | Source id of the table to join with the source one.                                              |
| join_type      | string      | 'LEFT','RIGHT', 'INNER', or None                                                                 |
| source_columns | column_list | Column/s to join from the source table. Col index in list must match with `joined_colums` param. |
| joined_colums  | column_list | Column/s to join from the join table. Col index in list must match with `source_columns` param.  |


## Example

```python
# Perform a RIGHT join, joining on keys 'MONTH'/'MONTH_NUM', 'FIPS/ZIP_CODE', and 'COVID_DEATHS'
source.transform(
  transform_name='rasgo_join',
  join_table_id=363,
  join_type='RIGHT',
  source_columns=['MONTH', 'FIPS', 'COVID_DEATHS'],
  joined_colums=['MONTH_NUM', 'ZIP_CODE', 'COVID_DEATHS']
).preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/rasgo_join/rasgo_join.sql" %}

