

# substring

This function creates a new column that contains a substring of either a fixed value or another column in your dataset.


## Parameters

|  Argument  |  Type  |                                                                                                       Description                                                                                                       |
| ---------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| target_col | column | A string column from which to subselect                                                                                                                                                                                 |
| start_pos  | value  | The position of the string from which to begin selection. Index begins at 1, not 0. May be a negative number, in which case the value represents the positions from the end of the string from which to begin selection |
| end_pos    | value  | The number of characters to select. If left empty, select through the end of the string.                                                                                                                                |


## Example

```python
source = rasgo.read.source_data(source_id)

t1 = source.transform(
    transform_name='substring',
    target_col="COLUMN_NAME",
    start_pos=-5
  )

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/substring/substring.sql" %}

