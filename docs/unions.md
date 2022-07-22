

# union

Union one or multiple tables with the base table.
Looks at all columns in each table and finds columns in common across all of them to keep in the final table.


## Parameters

|       Name        |    Type    |                                                                   Description                                                                    | Is Optional |
| ----------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| union_tables      | table_list | tables to union with the base table                                                                                                              |             |
| remove_duplicates | boolean    | Defaults to False. Set to True to use UNION, which removes duplicate rows. Set to False to use UNION ALL, which keeps rows that are duplicated.  | True        |


## Example

```python
d1 = rasgo.get.dataset(dataset_id)
d2 = rasgo.get.dataset(dataset_id_2)
d3 = rasgo.get.dataset(dataset_id_3)

union_ds = d1.unions(
    union_tables=[d2.fqtn, d3.fqtn]
    remove_duplicates=True
)

union_ds.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/unions/unions.sql" %}

