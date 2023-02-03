

# new_columns

## Build new columns, using SQL formulas.

### Required Inputs
- Calculated Column: the formula for the new column you want to build

### Optional Inputs
- Alias: name for your columns

### Notes
- Supports any SQL column functions that are compatible with your data warehouse


## Parameters

|        Name        |          Type          |                 Description                  | Is Optional |
| ------------------ | ---------------------- | -------------------------------------------- | ----------- |
| calculated_columns | calculated_column_list | List of SQL formulas to generate new columns |             |


## Example

```python
ds2 = ds.new_columns(
    calculated_columns={
          calcuated_column: 'POWER(COLUMN_NAME, 3)',
          alias: 'COLUMN_NAME_Cubed'
        }
    )
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/new_columns/new_columns.sql" %}

