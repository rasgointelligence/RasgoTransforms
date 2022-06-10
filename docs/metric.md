

# metric

Calculate metric values given a metric definition

## Parameters

|       Name       |    Type     |                                                                                          Description                                                                                           | Is Optional |
| ---------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| timestamp        | column      | The date/datetime column by which the metric will be aggregated                                                                                                                                |             |
| target_sql       | column      | The target column used to calculate the metric, can also be a sql string '(e.g. cast(target_column as string)')                                                                                |             |
| aggregation_type | string      | the Aggregation method used to calculate the metric (e.g. 'sum', 'count_distinct', 'max')                                                                                                      |             |
| time_grain       | string      | The time grain (day, week, month, quarter, year) used to create the datespine that the metric is aggregated by                                                                                 |             |
| dimensions       | column_list | List of columns used to group by in metric aggregation                                                                                                                                         | True        |
| filters          | list        | List of objects containing filters used to filter the source data. A filter object must contain the fields 'field', 'operator', and 'value'. String values should be wrapped in single quotes. | True        |
| alias            | string      | The name of the output metric value column                                                                                                                                                     | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.metric(
    source_table="DBTTEST.TUTORIAL.ORDERS",
    timestamp='ORDERDATE',
    target_sql=SALESAMOUNT',
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

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/metric/metric.sql" %}

