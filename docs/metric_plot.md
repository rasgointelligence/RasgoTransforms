

# metric_plot

Compare metrics on a timeseries plot

## Parameters

|        Name         |        Type        |                                                                                                                                                                           Description                                                                                                                                                                           | Is Optional |
| ------------------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| metrics             | comparison_list    | List of input metrics/calculations to plot                                                                                                                                                                                                                                                                                                                      |             |
| filters             | filter_list        | Filter logic on one or more columns. Can choose between a simple comparison filter or advanced filter using free text.                                                                                                                                                                                                                                          | True        |
| group_by_dimensions | dimension_list     | Categorical column(s) by which to pivot the calculated metrics. Including this argument will generate a new metric calculation for each distinct value in the group by column. If this column has more than 20 distinct values, the plot will not generate.                                                                                                     | True        |
| timeseries_options  | timeseries_options | (Required if 'x_axis' is a date/datetime type) A dictionary containing the start and end dates as well as the time grain which will be used to create the datespine for the x_axis. Time grain options are ('day', 'week', 'month', 'year', 'quarter', and 'all') Example: {   'start_date': '2021-12-01',   'end_date': '2022-07-01',   'time_grain': 'day' }  |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.plot(
  timeseries_options={
      'start_date': '2021-02-01',
      'end_date': '2021-03-01',
      'time_grain': 'day',
  },
  comparisons=[{
      'target_expression': 'SALESAMOUNT',
      'type': 'SUM',
      'time_dimension': 'ORDERDATE',
      'name': 'sales_revenue',
      'filters': [
          {
              'columnName': 'UNITPRICE',
              'operator': '>=',
              'comparisonValue': 10
          }
      ],
      'secondary_calculation': {
          'type': 'period_to_date',
          'period': 'quarter',
          'aggregate': 'max'
      }
  }])
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/metric_plot/metric_plot.sql" %}

