

# filter

Apply one or more column filters to the dataset

## Parameters

|       Name        |    Type     |                Description                | Is Optional |
| ----------------- | ----------- | ----------------------------------------- | ----------- |
| filter_statements | filter_list | list of dictionaries representing filters |             |


## Example

```python
ds = rasgo.get.dataset(74)

ds2 = ds.filter(filter_statements=[{'advancedFilterString':'PRODUCTKEY < 500'}])
ds2.preview()

ds3 = ds.filter(filter_statements=[{'columnName':'PRODUCTKEY', 'operator':'>', 'comparisonValue':'101'}])
ds3.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/new_filter/new_filter.sql" %}

