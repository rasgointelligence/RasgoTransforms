

# line_chart

Generate a binned approximation of a continuous column

## Parameters

|  Argument   |   Type   |                              Description                               | Is Optional |
| ----------- | -------- | ---------------------------------------------------------------------- | ----------- |
| dimension   | column   | qualitative values such as names or dates to segment your metric(s) by |             |
| metrics     | agg_dict | numeric, quantitative values that you can measure                      |             |
| num_buckets | value    | max number of buckets to create; defaults to 200                       | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.line_chart(column='SALESAMOUNT')
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/line_chart/line_chart.sql" %}

