

# plot

Visualize a dataset flexibly, depending on axes and metrics chosen

## Parameters

|     Name     |      Type       |                                                                                                                        Description                                                                                                                         | Is Optional |
| ------------ | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| x_axis       | column          | X-axis by which to view your data. Can be categorical, datetime, or numeric. If categorical, will output a bar chart. If datetime or numerical, will result in a line chart.                                                                               |             |
| metrics      | column_agg_list | numeric, quantitative values that you can measure                                                                                                                                                                                                          |             |
| num_buckets  | value           | max number of buckets to create; defaults to 200                                                                                                                                                                                                           | True        |
| filters      | filter_list     | Filter logic on one or more columns. Can choose between a simple comparison filter or advanced filter using free text.                                                                                                                                     | True        |
| x_axis_order | value           | Either ASC or DESC, depending on if you'd like to order your bar chart X-axis returned in ascending or descending order                                                                                                                                    | True        |
| group_by     | column          | A categorical column by which to pivot the calculated metrics. Including this argument will generate a new metric calculation for each distinct value in the group by column. If this column has more than 20 distinct values, the plot will not generate. | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.plot(x_axis='TEMPERATURE', metrics={
          'RAINFALL': ['SUM', 'AVG'],
          'SNOWFALL': ['SUM', 'AVG']
      })
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/plot/snowflake/plot.sql" %}

