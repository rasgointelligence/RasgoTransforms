

# metric

Calculate metric values given a metric definition

## Parameters

|      Name      |    Type     |                                                                                          Description                                                                                           | Is Optional |
| -------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| time_dimension | column      | The date/datetime column by which the metric will be aggregated                                                                                                                                |             |
| target_column  | column      | The target column used to calculate the metric, can also be a sql string '(e.g. cast(target_column as string)')                                                                                |             |
| aggregation    | agg         | the Aggregation method used to calculate the metric (e.g. 'sum', 'count_distinct', 'max') or 'expression' if the metric is an expression metric                                                |             |
| time_grain     | date_part   | The time grain (day, week, month, quarter, year) used to create the datespine that the metric is aggregated by                                                                                 |             |
| alias          | string      | The name of the output metric value column                                                                                                                                                     | True        |
| dimensions     | column_list | List of columns used to group by in metric aggregation                                                                                                                                         | True        |
| filters        | filter_list | List of objects containing filters used to filter the source data. A filter object must contain the fields 'field', 'operator', and 'value'. String values should be wrapped in single quotes. | True        |
| start_date     | timestamp   | The start of the period for which metric values will be calculated (2010-01-01 if unset)                                                                                                       | True        |
| end_date       | timestamp   | The end of the period for which metric values will be calculated (current day if unset)                                                                                                        | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.metric(
    time_dimension='ORDERDATE',
    column='SALESAMOUNT',
    aggregation='sum',
    alias='weekly_sales',
    time_grain='week',
    dimensions=['PRODUCTKEY'],
    filters=[
      {
        'field': 'UNITPRICE',
        'operator': '>=',
        'value': 1
      },
      {
        'field': 'DEPARTMENT',
        'operator': 'like'
        'value': "'%electronics'"
      }
    ]
)
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/metric/metric.sql" %}

