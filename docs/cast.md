

# cast

Cast selected columns to a new type


## Parameters

|       Name        |      Type       |                                                  Description                                                   | Is Optional |
| ----------------- | --------------- | -------------------------------------------------------------------------------------------------------------- | ----------- |
| casts             | cast_value_dict | A dict where the keys are columns and the values are the new type to cast them to.                             |             |
| overwrite_columns | boolean         | to overwrite column names with the new casted column, use 'true'. otherwise, use 'false'. defaults to 'false'. | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds_casted = ds.cast(
  casts={
    'DS_WEATHER_ICON':'INT',
    'DS_DAILY_HIGH_TEMP':'STRING',
    'DS_DAILY_LOW_TEMP':'INT'
  },
  overwrite_columns=True
)

ds_casted.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/cast/cast.sql" %}

