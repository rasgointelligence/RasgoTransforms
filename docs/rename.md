

# rename

Rename columns by passing a renames dict.


## Parameters

|  Name   |       Type        |                                      Description                                       | Is Optional |
| ------- | ----------------- | -------------------------------------------------------------------------------------- | ----------- |
| renames | column_value_dict | A dict representing each existing column to be renamed and its corresponding new name. |             |


## Example

```python
ds = rasgo.get.dataset(dataset_id)

ds2 = ds.rename(renames={
      'DS_WEATHER_ICON': 'Weather',
      'DS_DAILY_HIGH_TEMP': 'High_Temp',
      'DS_DAILY_LOW_TEMP': 'Low_Temp'
})

ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/rename/rename.sql" %}

