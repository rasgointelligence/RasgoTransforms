

# standard_scaler

This function scales a column by removing the mean and scaling by standard deviation.


## Parameters

|     Argument     |    Type     |                   Description                    |
| ---------------- | ----------- | ------------------------------------------------ |
| columns_to_scale | column_list | A list of numeric columns that you want to scale |


## Example

```python
source = rasgo.read.source_data(source_id)

t1 = source.transform(
    transform_name='standard_scaler',
    columns_to_scale=['DS_DAILY_HIGH_TEMP','DS_DAILY_LOW_TEMP']
  )

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/standard_scaler/standard_scaler.sql" %}

