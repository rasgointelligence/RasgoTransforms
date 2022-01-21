

# lag_aggregate

Temporally aggregates a continuous column (i.e. sales or quantity) over one or more time windows, producing a column per window.

Best used in time series forecasting or analysis when you need to analyze performance over a variety of historical periods.


## Parameters

|  Argument   |    Type     |                                                                                                                            Description                                                                                                                             | Is Optional |
| ----------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| group_by    | column_list | Column(s) to group by when aggregating the target number                                                                                                                                                                                                           |             |
| windows     | value_list  | List of numeric intervals to apply to the date column when calculating the lag windows for the aggregation.  Positive values apply a look-back window; negative values apply a look-forward window. One column will be created for each window value in the list.  |             |
| date_part   | date_part   | Date part to use when calculating the lookback intervals (i.e. day, week, year, etc.) Must be one of the values listed in [Supported Date and Time Parts](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts)    |             |
| agg         | agg_method  | The aggregation to use when calculating the aggregate over the lag window (i.e. SUM, MIN, MAX, etc.)                                                                                                                                                               |             |
| anchor_date | value       | Optional anchor date to use as a starting point for substracting the window values before aggregating. If omitted, CURRENT_DATE() is used.                                                                                                                         | True        |
| column      | column      | Continuous value to aggregate, such as sales amount or quantity.                                                                                                                                                                                                   |             |
| event_date  | column      | Date column in transactional / fact table                                                                                                                                                                                                                          |             |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds2 = internet_sales.lag_aggregate(
      group_by=['PRODUCTKEY'],
      windows=[1, 7, 30, 60, 90],
      date_part='day',
      anchor_date='2012-01-01',
      agg='SUM',
      column='SALESAMOUNT',
      event_date='ORDERDATE')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/lag_aggregate/lag_aggregate.sql" %}

