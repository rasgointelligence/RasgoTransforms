

# to_date

Creates a column of a date/timestamp type from some other column

## Parameters

|     Argument      |    Type     |                                                                                                                                Description                                                                                                                                |
| ----------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| date_columns      | column_list | names of column(s) you want to convert to dates/timestamps                                                                                                                                                                                                                |
| format_expression | string      | the format to use to parse the dates. See [this Snowflake doc](https://docs.snowflake.com/en/user-guide/date-time-input-output.html#about-the-format-specifiers-in-this-section) for information valid formats. If this is not provided, it will default to `YYYY-MM-DD`. |


## Example

```python
source = rasgo.read.source_data(source_id)

t1 = source.transform(
  transform_name='to_date',
  format_expression='YYYY-MM-DD',
  date_columns=['dt_str']
)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/to_date/to_date.sql" %}

