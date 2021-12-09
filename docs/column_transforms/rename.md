

# rename

Rename columns in col_list with names specified in new_names.

The ordinal position of columns in `col_list` must match the desired new names in `new_names`.


## Parameters

| Argument  |    Type     |                              Description                              |
| --------- | ----------- | --------------------------------------------------------------------- |
| col_list  | column_list | A list representing each existing column that needs to be renamed.    |
| new_names | value_list  | A list of strings containing the new names for the specified columns. |


## Example

```python
source = rasgo.get.dataset(dataset_id)

t1 = source.transform(
    transform_name='rename',
    col_list=["DS_WEATHER_ICON", "DS_DAILY_HIGH_TEMP", "DS_DAILY_LOW_TEMP"],
    new_names=["WEATHER", "HIGH_TEMP", "LOW_TEMP"]
)

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rename/rename.sql" %}

