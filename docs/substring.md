

# substring

This function creates a new column that contains a substring of either a fixed value or another column in your dataset.


## Parameters

|  Argument  |  Type  |                                                                                                       Description                                                                                                       | Is Optional |
| ---------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| target_col | column | A string column from which to subselect                                                                                                                                                                                 |             |
| start_pos  | int    | The position of the string from which to begin selection. Index begins at 1, not 0. May be a negative number, in which case the value represents the positions from the end of the string from which to begin selection |             |
| end_pos    | int    | The number of characters to select. If left empty, select through the end of the string.                                                                                                                                | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.substring(target_col='WEATHER_DESCRIPTION', start_pos=3)
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/substring/substring.sql" %}

