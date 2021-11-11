

# rasgo_cast

This function creates new columns for all columns included in `col_list`. Each of the new columns is cast to a new data type, indicated in `type_list`.

The ordinal position of columns in `col_list` must match the desired output data type in `type_list`.

Caution! Executing this transformation on a large dataset can be computationally expensive!


## Parameters

| Argument  |    Type     |                             Description                              |
| --------- | ----------- | -------------------------------------------------------------------- |
| col_list  | column_list | A list representing each existing column to have a changed type.     |
| type_list | value_list  | A list of strings containing the types to which to cast the columns. |


## Example

```python
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
    transform_name='rasgo_cast',
    col_list=["DS_WEATHER_ICON", "DS_DAILY_HIGH_TEMP", "DS_DAILY_LOW_TEMP"],
    type_list=["INT", "STRING", "STRING"]
)

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_cast/rasgo_cast.sql" %}

