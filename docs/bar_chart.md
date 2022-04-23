

# bar_chart

Compare categorical values across one or more metrics

## Parameters

|     Argument      |      Type       |                                  Description                                   | Is Optional |
| ----------------- | --------------- | ------------------------------------------------------------------------------ | ----------- |
| dimension         | column          | qualitative values such as names or dates to segment your metric(s) by         |             |
| metrics           | column_agg_list | numeric, quantitative values that you can measure                              |             |
| filter_statements | string_list     | List of SQL where statements to filter the table by, i.e. 'COLUMN IS NOT NULL' | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.bar_chart(dimension='FIPS', metrics={
          'COL_1': ['SUM', 'AVG'],
          'COL_2': ['SUM', 'AVG']
      })
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/bar_chart/bar_chart.sql" %}

