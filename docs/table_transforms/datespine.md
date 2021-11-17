

# datespine

This operation generates a table that contains one row per interval that exists between the two input dates. It will then join it on the source table based on the user specified column.

The table with the intervals will the in the form of `(id, start, end)`.

When joining, all intervals are considered to be start-inclusive, end-exclusive, or `(start, end]`. The join will be an outer join on the interval table such that all intervals are present and all data that does not fall into one of those intervals is excluded. It's essentially:

```
SELECT user_table.*, intervals.*
FROM intervals
  LEFT OUTER JOIN user_table
  ON ...
```


## Parameters

|    Argument     |   Type    |                                                                           Description                                                                            |
| --------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| date_col        | column    | The name of the column from the source data set that we'll be binning into some interval. This must be some sort of date or time column.                         |
| start_timestamp | timestamp | The timestamp to start calculating from; this will be included in the output set; this timestamp will have no timezone                                           |
| end_timestamp   | timestamp | The timestamp to calculate to; this will be included in the output set; this timestamp will have no timezone                                                     |
| interval_type   | string    | the datepart to slice by. For interval types, see [this Snowflake doc.](https://docs.snowflake.com/en/sql-reference/data-types-datetime.html#interval-constants) |


## Example

```python
source = rasgo.read.source_data(source_id)

t1 = source.transform(
  transform_name='datespine',
  date_col='event_dt',
  start_timestamp='2017-01-01 12:00:00',
  start_timestamp='2020-01-01 12:00:00',
  interval_type='month'
)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/datespine/datespine.sql" %}
