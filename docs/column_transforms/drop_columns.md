

# drop_columns

Drop columns by passing either an include_cols list of columns to include or an exclude_cols list of columns to exclude.

Passing both include_cols and exclude_cols will result in an error.


## Parameters

|   Argument   |    Type     |                                                   Description                                                   |
| ------------ | ----------- | --------------------------------------------------------------------------------------------------------------- |
| include_cols | column_list | A list of the columns from the dataset you want to keep.                                                        |
| exclude_cols | column_list | A list of the columns from the dataset you want to drop. Any columns not in the exclude_cols list will be kept. |


## Example

```python
source = rasgo.get.dataset(dataset_id)

  t1 = source.transform(
      transform_name='drop_columns',
      include_cols=["DS_WEATHER_ICON", "DS_DAILY_HIGH_TEMP", "DS_DAILY_LOW_TEMP"]
  )

  t2 = source.transform(
      transform_name='drop_columns',
      exclude_cols=["DS_CLOUD_COVER", "DS_TOTAL_RAINFALL"]
  )

  t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/drop_columns/drop_columns.sql" %}

