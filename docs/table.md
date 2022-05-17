

# table

Compare categorical values across one or more metrics

## Parameters

|       Name        |    Type     |                Description                | Is Optional |
| ----------------- | ----------- | ----------------------------------------- | ----------- |
| filter_statements | filter_list | list of dictionaries representing filters | True        |
| num_rows          | value       | number of rows to return; defaults to 10  | True        |


## Example

```python
ds = rasgo.get.dataset(id)
ds2 = ds.table()
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/table/table.sql" %}

