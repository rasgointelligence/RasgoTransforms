

# standard_scaler

This function scales a column by removing the mean and scaling by standard deviation.

If you omit averages and standarddevs, the function will compute the average and standard deviation of each column. Pass averages and standarddevs values if you want to override the calculation with static values for each column.


## Parameters

|     Argument     |    Type     |                                                                                      Description                                                                                       | Is Optional |
| ---------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| columns_to_scale | column_list | A list of numeric columns that you want to scale                                                                                                                                       |             |
| averages         | value_list  | An optional argument representing a list of the static averages to use for each column in columns_to_scale. If omitted, the averages are calculated directly off each column.          | True        |
| standarddevs     | value_list  | An optional argument representing a list of the static standard deviations to use for each column in columns_to_scale. If omitted, the values are calculated directly off each column. | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.standard_scaler(columns_to_scale=['DS_DAILY_HIGH_TEMP','DS_DAILY_LOW_TEMP'])
ds2.preview()

ds2b = ds.standard_scaler(columns_to_scale=['DS_DAILY_HIGH_TEMP','DS_DAILY_LOW_TEMP'],
  averages=[68, 52],
  standarddevs=[12, 8])
ds2b.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/standard_scaler/standard_scaler.sql" %}

