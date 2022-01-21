

# cast

Cast selected columns to a new type


## Parameters

| Argument |      Type       |                                    Description                                     | Is Optional |
| -------- | --------------- | ---------------------------------------------------------------------------------- | ----------- |
| casts    | cast_value_dict | A dict where the keys are columns and the values are the new type to cast them to. |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds_casted = ds.transform(
  transform_name='cast',
  casts={
    'DS_WEATHER_ICON':'INT',
    'DS_DAILY_HIGH_TEMP':'STRING',
    'DS_DAILY_LOW_TEMP':'INT'
  }
)

ds_casted.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/cast/cast.sql" %}

