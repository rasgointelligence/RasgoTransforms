

# drop_columns

Drop columns by passing either an include_cols list of columns to include or an exclude_cols list of columns to exclude.

Passing both include_cols and exclude_cols will result in an error.


## Parameters

|     Name     |    Type     |                                                   Description                                                   | Is Optional |
| ------------ | ----------- | --------------------------------------------------------------------------------------------------------------- | ----------- |
| include_cols | column_list | A list of the columns from the dataset you want to keep.                                                        | True        |
| exclude_cols | column_list | A list of the columns from the dataset you want to drop. Any columns not in the exclude_cols list will be kept. | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2a = ds.drop_columns(include_cols=["DS_WEATHER_ICON", "DS_DAILY_HIGH_TEMP"])
ds2a.preview()

ds2b = ds.drop_columns(exclude_cols=["DS_CLOUD_COVER", "DS_TOTAL_RAINFALL"])
ds2b.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/drop_columns/drop_columns.sql" %}

