

# metric

Calculate metric values given a metric definition

## Parameters

|       Name        |    Type     |                                                                                          Description                                                                                           | Is Optional |
| ----------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| time_dimension    | column      | The date/datetime column by which the metric will be aggregated                                                                                                                                |             |
| target_expression | column      | The target column used to calculate the metric, can also be a sql string '(e.g. cast(target_column as string)')                                                                                |             |
| aggregation_type  | agg         | the Aggregation method used to calculate the metric (e.g. 'sum', 'count_distinct', 'max')                                                                                                      |             |
| time_grain        | string      | The time grain (day, week, month, quarter, year) used to create the datespine that the metric is aggregated by                                                                                 |             |
| dimensions        | column_list | List of columns used to group by in metric aggregation                                                                                                                                         | True        |
| filters           | filter_list | List of objects containing filters used to filter the source data. A filter object must contain the fields 'field', 'operator', and 'value'. String values should be wrapped in single quotes. | True        |
| alias             | string      | The name of the output metric value column                                                                                                                                                     | True        |
| start_date        | timestamp   | The start of the period for which metric values will be calculated (2010-01-01 if unset)                                                                                                       | True        |
| num_days          | int         | The number of days after the start_date for which metric values will be calculated (7300 if unset)                                                                                             | True        |
| flatten           | bool        | (Default: true) If true, the resulting data will be pivoted on the distinct dimension columns                                                                                                  | True        |
| max_num_groups    | int         | (Default: 10) The maximum number of groups in a dimention to group by. Groups are ordered by number of records and the top groups are chosen and others are added to a 'Other' group.          | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.metric(
    source_table="DBTTEST.TUTORIAL.ORDERS",
    time_dimension='ORDERDATE',
    target_expression=SALESAMOUNT',
    aggregation_type='sum',
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

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/metric/snowflake/metric.sql" %}

