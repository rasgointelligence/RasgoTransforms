

# table

Compare categorical values across one or more metrics

## Parameters

|   Name   |    Type     |                                                      Description                                                       | Is Optional |
| -------- | ----------- | ---------------------------------------------------------------------------------------------------------------------- | ----------- |
| filters  | filter_list | Filter logic on one or more columns. Can choose between a simple comparison filter or advanced filter using free text. | True        |
| num_rows | value       | number of rows to return; defaults to 10                                                                               | True        |


## Example

```python
ds = rasgo.get.dataset(id)
ds2 = ds.table()
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/table/table.sql" %}

