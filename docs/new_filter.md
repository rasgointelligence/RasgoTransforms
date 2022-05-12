

# filter

Apply one or more column filters to the dataset

## Parameters

| Name  |    Type     |                Description                | Is Optional |
| ----- | ----------- | ----------------------------------------- | ----------- |
| items | filter_list | list of dictionaries representing filters |             |


## Example

```python
ds = rasgo.get.dataset(74)

# comma separated list of 'WHERE' clauses
ds2 = ds.filter(items=['PRODUCTKEY < 500'])
ds2.preview()

# full filtering with a column, operator, and comparison value
ds3 = ds.filter(items=[{'columnName':'PRODUCTKEY', 'operator':'>', 'comparisonValue':'101'}])
ds3.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/new_filter/new_filter.sql" %}

