

# rename

Rename columns by passing a renames dict.


## Parameters

| Argument |       Type        |                                      Description                                       |
| -------- | ----------------- | -------------------------------------------------------------------------------------- |
| renames  | column_value_dict | A dict representing each existing column to be renamed and its corresponding new name. |


## Example

```python
source = rasgo.get.dataset(dataset_id)

t1 = source.transform(
    transform_name='rename',
    renames={
      'DS_WEATHER_ICON': 'Weather',
      'DS_DAILY_HIGH_TEMP': 'High_Temp',
      'DS_DAILY_LOW_TEMP': 'Low_Temp'
})

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/new_rename/new_rename.sql" %}

