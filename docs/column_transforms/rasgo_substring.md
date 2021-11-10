

# rasgo_substring

This function creates a new column that contains a substring of either a fixed value or another column in your dataset.

# TODO: finish description


## Parameters

| Argument  |  Type  |                                                                                                       Description                                                                                                       |
| --------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| col_expr  | string | A string column from which to subselect                                                                                                                                                                                 |
| start_pos | int    | The position of the string from which to begin selection. Index begins at 1, not 0. May be a negative number, in which case the value represents the positions from the end of the string from which to begin selection |
| end_pos   | int    | The number of characters to select. If left null, automatically select through the end of the string.                                                                                                                   |


## Example

```python
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
    transform_name='rasgo_substring',
    new_cols = [column_name, 1, 5]
  )

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_substring/rasgo_substring.sql" %}

