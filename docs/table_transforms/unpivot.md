

# unpivot

Performs a UNPIVOT operation, rotating a table by transforming columns into rows

## Parameters

|     Argument     |    Type     |                                                                                     Description                                                                                     | Is Optional |
| ---------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| value_column     | string      | The name to assign to the generated column that will be populated with the values from the columns in the column list                                                               |             |
| name_column      | string      | The name to assign to the generated column that will be populated with the names of the columns in the column list                                                                  |             |
| column_list_vals | column_list | List of columns in the source table that will be narrowed into a single pivot column. The column names will populate name_column, and the column values will populate value_column. |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.unpivot(
  value_column="COVID_NEW_CASES",
  name_column="YEAR",
  column_list=["2020", "2021"]
)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/unpivot/unpivot.sql" %}

