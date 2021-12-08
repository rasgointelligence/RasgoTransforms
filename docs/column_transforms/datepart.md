

# datepart

Extracts a specific part of a date column. For example, if the input is '2021-01-01', you can ask for the year and get back 2021.

## Parameters

|   Argument   |    Type     |                                                                                           Description                                                                                            |
| ------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| date_columns | column_list | names of column(s) you want to date-part                                                                                                                                                         |
| date_part    | date_part   | the desired grain of the date; an exhaustive list of valid date parts can be [found here](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts). |


## Example

```python
source = rasgo.get.dataset(dataset.id)

t1 = source.transform(
  transform_name='datepart',
  date_part = 'month',
  date_columns = ['DATE', "OTHER_DATE_COL"]
)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/datepart/datepart.sql" %}

