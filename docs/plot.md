

# plot

Visualize a dataset flexibly, depending on axes and metrics chosen

## Parameters

|     Name     |      Type       |                                                                                                                             Description                                                                                                                             | Is Optional |
| ------------ | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| x_axis       | x_axis          | X-axis by which to view your data. Can be categorical, datetime, or numeric. If categorical, will output a bar chart. If datetime or numerical, will result in a line chart. Includes 'timeseries_options' for timeseries axis and 'bucket_count' for numeric axis. |             |
| aggregations | column_agg_list | numeric, quantitative values that you can measure                                                                                                                                                                                                                   |             |
| filters      | filter_list     | Filter logic on one or more columns. Can choose between a simple comparison filter or advanced filter using free text.                                                                                                                                              | True        |
| dimensions   | column_list     | Categorical column(s) by which to pivot the calculated metrics. Including this argument will generate a new metric calculation for each distinct value in the group by column. If this column has more than 20 distinct values, the plot will not generate.         | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.aggregate_plot(
  x_axis={
      'column': 'ORDERDATE',
      'type': 'timeseries',
      'timeseries_options': {
          'start_date': '2021-02-01',
          'end_date': '2021-03-01',
          'time_grain': 'day',
      }
  }, aggregations= {
      'RAINFALL': ['SUM', 'AVG'],
      'SNOWFALL': ['SUM', 'AVG']
  })
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/plot/plot.sql" %}

