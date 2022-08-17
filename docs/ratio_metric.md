

# metric

Calculate metric values given a metric definition

## Parameters

|       Name        |    Type     |                                                                                                   Description                                                                                                   | Is Optional |
| ----------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| time_dimension    | column      | The date/datetime column by which the metric will be aggregated                                                                                                                                                 |             |
| metrics           | agg_mapping | list of objects that define metrics as a column name, agg method, and alias. Each metric used in the target_expression must be in this list of metrics, the target_expression refers to metrics by their alias. |             |
| target_expression | column      | The target expression used to create the ratio metric                                                                                                                                                           |             |
| time_grain        | string      | The time grain (day, week, month, quarter, year) used to create the datespine that the metric is aggregated by                                                                                                  |             |
| dimensions        | column_list | List of columns used to group by in metric aggregation                                                                                                                                                          | True        |
| filters           | filter_list | List of objects containing filters used to filter the source data. A filter object must contain the fields 'field', 'operator', and 'value'. String values should be wrapped in single quotes.                  | True        |
| alias             | string      | The name of the output metric value column                                                                                                                                                                      | True        |
| start_date        | timestamp   | The start of the period for which metric values will be calculated (2010-01-01 if unset)                                                                                                                        | True        |
| end_date          | timestamp   | The start of the period for which metric values will be calculated (2010-01-01 if unset)                                                                                                                        | True        |
| max_num_groups    | int         | (Default: 10) The maximum number of groups in a dimention to group by. Groups are ordered by number of records and the top groups are chosen and others are added to a 'Other' group.                           | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.ratio_metric(
    source_table="DBTTEST.TUTORIAL.ORDERS",
    time_dimension='ORDERDATE',
    metrics=[
      {'alias': 'SALES_REVENUE', 'column': 'SALESAMOUNT', 'agg_method': 'SUM'},
      {'alias': 'SALES_VOLUME', 'column': 'ORDERNUMBER', 'agg_method': 'COUNT DISTINCT'}
    ],
    target_expression='SALES_REVENUE / SALES_VOLUME',
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
        'operator': 'like',
        'value': "'%electronics'"
      }
    ]
)
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/ratio_metric/ratio_metric.sql" %}

