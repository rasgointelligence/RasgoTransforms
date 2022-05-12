

# plot

Visualize a dataset flexibly, depending on axes and metrics chosen

## Parameters

|       Name        |      Type       |                                                                                 Description                                                                                  | Is Optional |
| ----------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| x_axis            | column          | X-axis by which to view your data. Can be categorical, datetime, or numeric. If categorical, will output a bar chart. If datetime or numerical, will result in a line chart. |             |
| metrics           | column_agg_list | numeric, quantitative values that you can measure                                                                                                                            |             |
| num_buckets       | value           | max number of buckets to create; defaults to 200                                                                                                                             | True        |
| filter_statements | string_list     | List of SQL where statements to filter the table by, i.e. 'COLUMN IS NOT NULL'                                                                                               | True        |
| order_direction   | string          | Either ASC or DESC, depending on if you'd like to order your bar chart X-axis returned in ascending or descending order                                                      | True        |


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

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/plot/plot.sql" %}

