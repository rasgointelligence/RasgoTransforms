

# datediff

Calculates the difference between two date, time, or timestamp expressions based on the date or time part requested. The function returns the result of subtracting the second argument from the third argument.

## Parameters

| Argument  |    Type     |                                                                                Description                                                                                 | Is Optional |
| --------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| date_part | date_part   | Must be one of the values listed in [Supported Date and Time Parts](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts)  |             |
| date_1    | mixed_value | Date column to subtract from `date_val_2`. Can be a date column, date, time, or timestamp.                                                                                 |             |
| date_2    | mixed_value | Date column to be subtracted by `date_val_1`. Can be a date column, date, time, or timestamp.                                                                              |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.datediff(date_part='year', date_1='END_DATE', date_2="'2022-01-01'")
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/column_transforms/datediff/snowflake/datediff.sql" %}

