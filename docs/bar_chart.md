

# bar_chart

Used for value distribution for string/bool columns, top n values, any x/y plot with discrete x

## Parameters

| Argument  |   Type   |                              Description                               | Is Optional |
| --------- | -------- | ---------------------------------------------------------------------- | ----------- |
| dimension | column   | qualitative values such as names or dates to segment your metric(s) by |             |
| metrics   | agg_dict | numeric, quantitative values that you can measure                      |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.aggregate(dimension='FIPS', metrics={
          'COL_1': ['SUM', 'AVG'],
          'COL_2': ['SUM', 'AVG']
      })
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/bar_chart/bar_chart.sql" %}

