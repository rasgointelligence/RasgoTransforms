

# datediff

Calculates the difference between two date, time, or timestamp expressions based on the date or time part requested.
Difference is calculated as date_1 - date_2.


## Parameters

|   Name    |    Type     |                                                                                Description                                                                                 | Is Optional |
| --------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| date_part | date_part   | Must be one of the values listed in [Supported Date and Time Parts](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts)  |             |
| date_1    | mixed_value | Starting date. Can be a date column, date, time, or timestamp.                                                                                                             |             |
| date_2    | mixed_value | Date to subtract from date_1. Can be a date column, date, time, or timestamp.                                                                                              |             |
| alias     | value       | Name for the new column created by the datediff.                                                                                                                           | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.datediff(date_part='year', date_1='END_DATE', date_2="'2022-01-01'")
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/datediff/snowflake/datediff.sql" %}

