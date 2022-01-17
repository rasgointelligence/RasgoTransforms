

# datespine

This transform generates a date spine for your date index, which can replace your date index column for modeling.

All intervals are considered to be start-inclusive and end-exclusive, or `(start, end]`. The join with the date spine will be an outer join such that all intervals are present and all data that does not fall into one of those intervals is excluded. It's essentially:

```
SELECT user_table.*, intervals.*
FROM intervals
  LEFT JOIN user_table
  ON ...
```


## Parameters

|    Argument     |   Type    |                                                                           Description                                                                            | Is Optional |
| --------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| date_col        | column    | The name of the column from the dataset that we'll be binning into some interval. This must be some sort of date or time column.                                 |             |
| start_timestamp | timestamp | The timestamp to start calculating from; this will be included in the output set; this timestamp will have no timezone                                           |             |
| end_timestamp   | timestamp | The timestamp to calculate to; this will be included in the output set; this timestamp will have no timezone                                                     |             |
| interval_type   | date_part | the datepart to slice by. For interval types, see [this Snowflake doc.](https://docs.snowflake.com/en/sql-reference/data-types-datetime.html#interval-constants) |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.datespine(
    date_col='event_dt',
    start_timestamp='2017-01-01',
    end_timestamp='2020-01-01',
    interval_type='month'
)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/datespine/datespine.sql" %}

