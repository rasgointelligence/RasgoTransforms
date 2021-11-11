

# rasgo_concat

This function creates a new column that contains a substring of either a fixed value or another column in your dataset.

Caution! Executing this transformation on a large dataset can be computationally expensive!
# TODO: finish description


## Parameters

| Argument |         Type         |                       Description                        |
| -------- | -------------------- | -------------------------------------------------------- |
| new_cols | List[string, string] | A list representing each existing column to be replaced. |
| col_expr | string               | The column targeted for data type change                 |
| new_type | string               | The desired output data type for the new column          |


## Example

```python
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
    transform_name='rasgo_substring',
    new_cols = [column_name, SNOWFLAKE_DATA_TYPE]
  )

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_cast/rasgo_cast.sql" %}

