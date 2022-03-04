

# dateadd

Adds the specified value for the specified date or time part to a date, time, or timestamp.

## Parameters

| Argument  |    Type     |                                                                                Description                                                                                 | Is Optional |
| --------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| date_part | date_part   | Must be one of the values listed in [Supported Date and Time Parts](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts)  |             |
| date      | mixed_value | Date column to increment. Can be a date column, date, time, or timestamp.                                                                                                  |             |
| offset    | int         | Numeric value to increment the date by.                                                                                                                                    |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.dateadd(date_part='year', date='END_DATE', offset=3)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/column_transforms/dateadd/snowflake/dateadd.sql" %}

