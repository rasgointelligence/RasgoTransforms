

# rasgo_concat

This function creates a new column that contains a substring of either a fixed value or another column in your dataset.

# TODO: finish description


## Parameters

| Argument |            Type            |                                Description                                 |
| -------- | -------------------------- | -------------------------------------------------------------------------- |
| new_cols | List[string, List[string]] | A list representing each new column to be created.                         |
| col_expr | string                     | The column expression intended to be used as the base of the concatenation |
| vals     | string                     | A list containing the expressions to concatenate to the base `col_expr`    |


## Example

```python
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
    transform_name='rasgo_substring',
    new_cols = [[column_name, ['this-fixed-string', second_col_name]]]
  )

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_concat/rasgo_concat.sql" %}

