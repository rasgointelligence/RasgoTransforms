

# to_date

Creates a column of a date/timestamp type from a string or other non-date column.

See [this Snowflake doc](https://docs.snowflake.com/en/user-guide/date-time-input-output.html#about-the-format-specifiers-in-this-section) for information about valid formats.


## Parameters

| Argument |       Type        |                                              Description                                               | Is Optional |
| -------- | ----------------- | ------------------------------------------------------------------------------------------------------ | ----------- |
| dates    | column_value_dict | dict where the values are the date columns and the keys are the date formats to use for the conversion |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.to_date(dates={
    'DATE_STRING':'YYYY-MM-DD',
    'DATE2_STR':'YYYY-DD-MM'
  })
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/column_transforms/to_date/to_date.sql" %}

