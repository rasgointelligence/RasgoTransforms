

# rasgo_datediff

Calculates the difference between two date, time, or timestamp expressions based on the date or time part requested. The function returns the result of subtracting the second argument from the third argument.

## Parameters

|  Argument  |  Type  |                                                                                Description                                                                                 |
| ---------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| date_part  | string | Must be one of the values listed in [Supported Date and Time Parts](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts)  |
| date_val_1 | string | Date column to subtract from `date_val_2`. Can be a date column, date, time, or timestamp.                                                                                 |
| date_val_2 | string | Date column to be subtracted by `date_val_1`. Can be a date column, date, time, or timestamp.                                                                              |


## Example

```python
source = rasgo.read.source_data(source.id)

# Create DateDiff col for year diff 'START_DATE' - 'END_DATE'
source.transform(
  transform_name='rasgo_datediff',
  date_part='year',
  date_val_1='END_DATE',
  date_col_2='START_DATE'
).preview()

# Subtract 'END_DATE' from start of 2022 new year
source.transform(
  transform_name='rasgo_datediff',
  date_val_1='END_DATE',
  date_val_2="'2022-01-01'"
).preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_datediff/rasgo_datediff.sql" %}

