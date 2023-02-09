

# metric

Calculate metric values given a metric definition

## Parameters

|        Name         |        Type        |                                                                                                                                                        Description                                                                                                                                                        | Is Optional |
| ------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| metrics             | comparison_list    | List of input metrics/calculations to plot                                                                                                                                                                                                                                                                                |             |
| date_settings       | timeseries_options | Date settings containing the start and end dates as well as the time grain which will be used to create the datespine for metric calculation. Time grain options are ('day', 'week', 'month', 'year', 'quarter', and 'all') Example: {   'start_date': '2021-12-01',   'end_date': '2022-07-01',   'time_grain': 'day' }  |             |
| filters             | filter_list        | Filter logic on one or more columns. Can choose between a simple comparison filter or advanced filter using free text.                                                                                                                                                                                                    | True        |
| group_by_dimensions | dimension_list     | Categorical column(s) by which to group the aggregated metrics. Including this argument will generate a new metric calculation for each distinct value in the group by column. If this column has more than 20 distinct values, the plot will not generate.                                                               | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.metric(
    metrics=[
      {
        "name": "AW_Sales_Revenue",
        "source_table": "RASGOLOCAL.PUBLIC.FQLUSMVCMIDATYSA",
        "type": "SUM",
        "target_expression": "SALESAMOUNT",
        "time_dimension": "ORDERDATE",
        "metric_dependencies": [],
      }
    ],
    filters=[],
    timeseries_options={
      "time_grain": "DAY",
      "start_date": {
        "direction": "past",
        "offset": 30,
        "datePart": "DAY",
        "type": "relative_date"
      },
      "end_date": {
        "direction": "past",
        "offset": 0,
        "datePart": "DAY",
        "type": "relative_date"
      }
    }
)
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/metric/metric.sql" %}

