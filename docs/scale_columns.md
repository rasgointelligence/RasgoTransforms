

# scale_columns

This function scales a column through standard or min/max scaling methods.


## Parameters

|       Name        |    Type     |                                                                                                                                                                    Description                                                                                                                                                                    | Is Optional |
| ----------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| columns_to_scale  | column_list | A list of numeric columns that you want to scale                                                                                                                                                                                                                                                                                                  |             |
| method            | string      | The method used to scale the column values ('standard' or 'min_max'). If 'standard' is chosen, this function scales a column by removing the mean and scaling by standard deviation. If 'min_max' is selected, this function scales a column by subtracting the min value in the column and dividing by the range between the max and min values. |             |
| overwrite_columns | boolean     | Optional: if true, the scaled values will overwrite values in 'columns_to_scale'. If false, new columns with the scaled values will be generated.                                                                                                                                                                                                 | True        |
| averages          | value_list  | Only applies when 'standard' method is chosen. This is an optional argument representing a list of the static averages to use for each column in columns_to_scale. If omitted, the averages are calculated directly off each column.                                                                                                              | True        |
| standarddevs      | int_list    | Only applies when 'standard' method is chosen. This is an optional argument representing a list of the static standard deviations to use for each column in columns_to_scale. If omitted, the values are calculated directly off each column.                                                                                                     | True        |
| minimums          | value_list  | Only applies when 'min_max' method is chosen. This is an optional argument representing a list of the static minimums to use for each column in columns_to_scale. If omitted, the minimums are calculated directly off each column.                                                                                                               | True        |
| maximums          | value_list  | Only applies when 'min_max' method is chosen. This is an optional argument representing a list of the static maximums to use for each column in columns_to_scale. If omitted, the values are calculated directly off each column.                                                                                                                 | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.scale_columns(columns_to_scale=['DS_DAILY_HIGH_TEMP','DS_DAILY_LOW_TEMP'], method='standard')
ds2.preview()

ds2b = ds.scale_columns(columns_to_scale=['DS_DAILY_HIGH_TEMP','DS_DAILY_LOW_TEMP'],
  averages=[68, 52],
  standarddevs=[12, 8],
  method='standard')
ds2b.preview()

ds2c = ds.scale_columns(columns_to_scale=['DS_DAILY_HIGH_TEMP','DS_DAILY_LOW_TEMP'],
  minimums=[52, 4],
  maximums=[101, 81],
  method='min_max')
ds2c.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/scale_columns/scale_columns.sql" %}

