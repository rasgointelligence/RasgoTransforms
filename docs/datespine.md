

# datespine

This transform generates a date spine for your date index, which can replace your date index column for modeling.

All intervals are considered to be start-inclusive and end-exclusive, or `[start, end]`. 
The join with the date spine will be an outer join such that all intervals are present 
and all data that does not fall into one of those intervals is excluded. 

If start_timestamp or end_timestamp are left blank, they will be automatically generated as the min or max timestamp 
in the 'date_col' column.

It's essentially:
```
SELECT user_table.*, intervals.*
FROM intervals
  LEFT JOIN user_table
  ON ...
```


## Parameters

|      Name       |   Type    |                                                                                    Description                                                                                     | Is Optional |
| --------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| date_col        | column    | The column used to create intervals. This must be a datetime column.                                                                                                               |             |
| interval_type   | date_part | A valid SQL datepart to slice the date_col. For interval types, see [this Snowflake doc.](https://docs.snowflake.com/en/sql-reference/data-types-datetime.html#interval-constants) |             |
| start_timestamp | timestamp | The timestamp to start calculating from;  this will be included in the output set; this timestamp will have no timezone                                                            | True        |
| end_timestamp   | timestamp | The timestamp to calculate to;  this will be included in the output set; this timestamp will have no timezone                                                                      | True        |


## Example

```python
ds = rasgo.get.dataset(74)

ds2 = ds.datespine(
    date_col='ORDERDATE',
    start_timestamp='2017-01-01',
    end_timestamp='2020-01-01',
    interval_type='month'
)
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/datespine/snowflake/datespine.sql" %}

