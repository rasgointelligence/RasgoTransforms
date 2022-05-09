

# sankey

Analyze the hierarchical record count of a series of columns by counting the number of records in each pair of values in hierarchically adjacent columns. The columns fed to this transformation should be categorical lables to be counted.

## Parameters

| Name  |    Type     |                               Description                               | Is Optional |
| ----- | ----------- | ----------------------------------------------------------------------- | ----------- |
| stage | column_list | Ordered list of categorial columns, from highest in hierarchy to lowest |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.sankey(stage=["ENGLISHCOUNTRYREGIONNAME", "STATEPROVINCENAME", "CITY"])
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/sankey/sankey.sql" %}

