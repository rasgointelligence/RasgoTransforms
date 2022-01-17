

# datepart

Extracts a specific part of a date column. For example, if the input is '2021-01-01', you can ask for the year and get back 2021.

An exhaustive list of valid date parts can be [found here](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts).


## Parameters

| Argument |     Type      |                                              Description                                              | Is Optional |
| -------- | ------------- | ----------------------------------------------------------------------------------------------------- | ----------- |
| dates    | datepart_dict | dict where keys are names of columns you want to date part and values are the desired date part grain |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.datepart(dates={
    'DATE_STRING':'year',
    'DATE2_STR':'month'
  })
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/datepart/datepart.sql" %}

