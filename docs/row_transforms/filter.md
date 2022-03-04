

# filter

Apply one or more column filters to the dataset

## Parameters

|     Argument      |    Type     |                                              Description                                              | Is Optional |
| ----------------- | ----------- | ----------------------------------------------------------------------------------------------------- | ----------- |
| filter_statements | string_list | List of where statements filter the table by. Ex. ["<col_name> = 'string'", "<col_name> IS NOT NULL"] |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.filter(filter_statements=['MONTH = 4', 'YEAR < 2021', 'COVID_DEATHS IS NOT NULL']
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/row_transforms/filter/filter.sql" %}

