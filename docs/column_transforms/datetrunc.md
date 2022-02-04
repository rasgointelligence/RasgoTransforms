

# datetrunc

Truncates a date to the datepart you specify. For example, if you truncate the date '10-31-2022' to the 'month', you would get '10-1-2022'.

For a list of valid dateparts, refer to [Supported Date and Time Parts](https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts)


## Parameters

| Argument |     Type      |                                                Description                                                 | Is Optional |
| -------- | ------------- | ---------------------------------------------------------------------------------------------------------- | ----------- |
| dates    | datepart_dict | dict where the keys are names of column(s) you want to datetrunc and the values are the desired date grain |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.datetrunc(
  dates = {
    'DATE':'month',
    'Timestamp':'hour'
  }
)

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/datetrunc/datetrunc.sql" %}

