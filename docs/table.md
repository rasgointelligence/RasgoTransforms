

# table

Compare categorical values across one or more metrics

## Parameters

|     Argument      |    Type     |                                  Description                                   | Is Optional |
| ----------------- | ----------- | ------------------------------------------------------------------------------ | ----------- |
| filter_statements | string_list | List of SQL where statements to filter the table by, i.e. 'COLUMN IS NOT NULL' | True        |
| num_rows          | value       | number of rows to return; defaults to 10                                       | True        |


## Example

```python
ds = rasgo.get.dataset(id)
ds2 = ds.table()
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/table/table.sql" %}

