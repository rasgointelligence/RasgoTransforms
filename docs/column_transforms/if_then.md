

# if_then

This function creates a new column based on the conditions provided in the `conditions` argument.

Output values should be of the same type, since they are constructing one new column.

A default value for the new column should be set, as should the output column name.


## Parameters

|  Argument  |       Type       |                                                            Description                                                            | Is Optional |
| ---------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| conditions | conditional_list | A nested list. In each inner list the first element would be the condition to check, and the second the value with which to fill. |             |
| default    | mixed_value      | The default value with which to fill the new column. Please enclose fixed strings in quotes inside of the argument (e.g., below)  |             |
| alias      | string           | The name of the output column in the new dataset.                                                                                 |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.if_then(conditions=[["DS_WEATHER_ICON like '%cloudy%'", 1]],
      default=2,
      alias="CLOUDY_WEATHER_FLAG")
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/if_then/if_then.sql" %}

