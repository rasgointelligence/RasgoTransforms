

# min_max_scaler

This function scales a column by subtracting the min value in the column and dividing by the range between the max and min values.

If you omit minimums and maximums, the function will compute the mins and maxes of each column. Pass minimums and maximiums values if you want to override the calculation with static values for each column.


## Parameters

|     Argument     |    Type     |                                                                                  Description                                                                                  | Is Optional |
| ---------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| columns_to_scale | column_list | A list of numeric columns that you want to scale                                                                                                                              |             |
| minimums         | value_list  | An optional argument representing a list of the static minimums to use for each column in columns_to_scale. If omitted, the minimums are calculated directly off each column. | True        |
| maximums         | value_list  | An optional argument representing a list of the static maximums to use for each column in columns_to_scale. If omitted, the values are calculated directly off each column.   | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.min_max_scaler(columns_to_scale=['DS_DAILY_HIGH_TEMP','DS_DAILY_LOW_TEMP'])
ds2.preview()

ds2b = ds.min_max_scaler(columns_to_scale=['DS_DAILY_HIGH_TEMP','DS_DAILY_LOW_TEMP'],
    minimums=[52, 4],
    maximums=[101, 81])
ds2b.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/min_max_scaler/min_max_scaler.sql" %}

