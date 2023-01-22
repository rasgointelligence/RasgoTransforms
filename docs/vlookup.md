

# vlookup

## Inspired by Excel... a VLookup experience that works in SQL

### Required Inputs
- Lookup Column: The column to look up in the Lookup Table. Make sure the column is named the same in both tables.
- Lookup Table: The table to look up the Lookup Column in.

### Optional Inputs
- Keep Columns: The columns to keep from the Lookup Table. If not provided, all columns from the Lookup Table will be kept.

### Notes
- For values that don't find a match in the lookup_column, you will see Null
- For columns that have the same name in both tables, the columns in the Lookup Table will be prefixed with the table name


## Parameters

|     Name      |    Type     |               Description               | Is Optional |
| ------------- | ----------- | --------------------------------------- | ----------- |
| lookup_column | column      | Column to look up in the lookup table   |             |
| lookup_table  | table       | Table to look up the lookup_column in   |             |
| keep_columns  | column_list | Columns to keep from the lookup table   | True        |


## Example

```python
internet_sales = rasgo.get.dataset(74)
customer = rasgo.get.dataset(55)
product = rasgo.get.dataset(75)

ds2 = internet_sales.vlookup(
  lookup_column='PRODUCTKEY',
  lookup_table=product.fqtn,
  keep_columns=['WEIGHT', 'ENGLISHDESCRIPTION']
)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/vlookup/vlookup.sql" %}

