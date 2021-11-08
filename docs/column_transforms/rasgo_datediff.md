

# rasgo_datediff

Calculates the difference between two date, time, or timestamp expressions based on the date or time part requested. The function returns the result of subtracting the second argument from the third argument.

## Parameters

|  Argument  |  Type  |                                                                                Description                                                                                 |
| ---------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| date_part  | string | Must be one of the values listed in [Supported Date and Time Parts](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts)  |
| date_col_1 | column | Date column to subtract from `date_col_2`. Must be a date column.                                                                                                          |
| date_col_2 | column | Date column to be subtracted by `date_col_1`. Must be a date column.                                                                                                       |


## Example

```python
source = rasgo.read.source_data(source.id)

# Create DateDiff col for 'START_DATE' - 'END_DATE'
t1 = source.transform(
  transform_name='rasgo_datediff',
  date_part='year',
  date_col_1='END_DATE',
  date_col_2='START_DATE'
)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_datediff/rasgo_datediff.sql" %}

