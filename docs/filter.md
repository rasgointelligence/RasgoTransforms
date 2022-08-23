

# filter

Filter the dataset. Supports two types of filters:
  1. Comparison filters, which compare the values in a column with a value
  2. Advanced filters, which support full SQL strings for custom filtering logic


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
ds3 = ds.filter(items=[{'columnName':'PRODUCTKEY', 'operator':'>', 'comparisonValue':'101', 'compoundBoolean': 'OR'}])
ds3.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/filter/filter.sql" %}

