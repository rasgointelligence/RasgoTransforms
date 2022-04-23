

# line_chart

Generate a binned approximation of a continuous column

## Parameters

|  Argument   |      Type       |                    Description                    | Is Optional |
| ----------- | --------------- | ------------------------------------------------- | ----------- |
| axis        | column          | axis column                                       |             |
| metrics     | column_agg_list | numeric, quantitative values that you can measure |             |
| num_buckets | value           | max number of buckets to create; defaults to 200  | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.line_chart(axis='TEMPERATURE', metrics={
          'RAINFALL': ['SUM', 'AVG'],
          'SNOWFALL': ['SUM', 'AVG']
      })
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/line_chart/line_chart.sql" %}

