

# sankey

Analyze the hierarchical record count of a series of columns by counting the number of records in each pair of values in hierarchically adjacent columns.

## Parameters

| Argument |    Type     |                         Description                          | Is Optional |
| -------- | ----------- | ------------------------------------------------------------ | ----------- |
| stage    | column_list | Ordered list of columns, from highest in hierarchy to lowest |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.funnel(stage=["ENGLISHCOUNTRYREGIONNAME", "STATEPROVINCENAME", "CITY"])
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/funnel/funnel.sql" %}

