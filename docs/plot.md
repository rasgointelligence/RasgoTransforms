

# plot

Visualize a dataset flexibly, depending on axes and metrics chosen

## Parameters

|        Name        |        Type        |                                                                                                                                                                           Description                                                                                                                                                                            | Is Optional |
| ------------------ | ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| x_axis             | column             | X-axis by which to view your data. Can be categorical, datetime, or numeric. If categorical, will output a bar chart. If datetime or numerical, will result in a line chart.                                                                                                                                                                                     |             |
| metrics            | column_agg_list    | numeric, quantitative values that you can measure                                                                                                                                                                                                                                                                                                                |             |
| num_buckets        | value              | max number of buckets to create; defaults to 200                                                                                                                                                                                                                                                                                                                 | True        |
| filters            | filter_list        | Filter logic on one or more columns. Can choose between a simple comparison filter or advanced filter using free text.                                                                                                                                                                                                                                           | True        |
| x_axis_order       | sort_direction     | Either ASC or DESC, depending on if you'd like to order your bar chart X-axis returned in ascending or descending order                                                                                                                                                                                                                                          | True        |
| group_by           | column             | A categorical column by which to pivot the calculated metrics. Including this argument will generate a new metric calculation for each distinct value in the group by column. If this column has more than 20 distinct values, the plot will not generate.                                                                                                       | True        |
| timeseries_options | timeseries_options | (Required if 'x_axis' is a date/datetime type) A dictionary containing the start and end dates as well as  the time grain which will be used to create the datespine for the x_axis. Time grain options are ('day', 'week', 'month', 'year', 'quarter', and 'all') Example: {   'start_date': '2021-12-01',   'end_date': '2022-07-01',   'time_grain': 'day' }  | True        |
| max_num_groups     | int                | (Default: 10) If group_by is specified, this is the max number of distinct groups that will be aggregated, all others will by combined in a 'Other' group                                                                                                                                                                                                        | True        |


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

