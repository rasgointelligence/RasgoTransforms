

# dateadd

Increments a date by the specified interval value.

## Parameters

|       Name        |    Type     |                                                                                            Description                                                                                            | Is Optional |
| ----------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| date_part         | date_part   | A valid SQL date part. Must be one of the values listed in [Supported Date and Time Parts](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts)  |             |
| date              | mixed_value | Date value to increment. Can be a column or literal of these types (date, datetime, time, or timestamp).                                                                                          |             |
| offset            | int         | Numeric value to increment the date by.                                                                                                                                                           |             |
| alias             | string      | Name of output column                                                                                                                                                                             | True        |
| overwrite_columns | boolean     | Optional: if true, the output column will replace the existing 'date' column                                                                                                                      | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.dateadd(date_part='year', date='END_DATE', offset=3, alias='THREE_YEARS_FUTURE')
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/dateadd/snowflake/dateadd.sql" %}

