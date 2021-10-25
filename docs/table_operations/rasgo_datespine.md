

# rasgo_datespine

Given a start timestamp, some interval, and the number of intervals to calculate, this operation gnerates a table N rows long with each row containing the sum of the interval and timestamp before it.

## Parameters

|    Argument     |   Type    |                                                                                                                                    Description                                                                                                                                    |
| --------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| start_timestamp | timestamp | the timestamp to start calculating from; this will be included in the output set; this timestamp will have no timezone                                                                                                                                                            |
| interval_amount | int       | the `interval_amount` and `interval_type` combine to create a Snowflake interval. In the example of `3 days`, `3` is the interval amount. This number can be any non-zero integer.                                                                                                |
| interval_type   | string    | the `interval_amount` and `interval_type` combine to create a Snowflake interval. In the example of `3 days`, `days` is the interval type. For interval types, see [this Snowflake doc.](https://docs.snowflake.com/en/sql-reference/data-types-datetime.html#interval-constants) |
| count           | int       | the total number of rows to generate; must be 1 or greater                                                                                                                                                                                                                        |


## Example

```py
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
  transform_name='rasgo_datespine',
  start_timestamp = '2017-01-01 12:00:00',
  interval_amount = 1,
  interval_type = 'month'
  count = 100)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/table_operations/rasgo_datespine/rasgo_datespine.sql" %}

