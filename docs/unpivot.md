

# unpivot

Performs a UNPIVOT operation, rotating a table by transforming columns into rows

## Parameters

|   Argument   |    Type     |                                                                                     Description                                                                                     | Is Optional |
| ------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| value_column | string      | The name to assign to the generated column that will be populated with the values from the columns in the column list                                                               |             |
| name_column  | string      | The name to assign to the generated column that will be populated with the names of the columns in the column list                                                                  |             |
| column_list  | column_list | List of columns in the source table that will be narrowed into a single pivot column. The column names will populate name_column, and the column values will populate value_column. |             |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds2 = internet_sales.unpivot(
    value_column="SALES_FEES",
    name_column="PRODUCT",
    column_list=["TAXAMT", "FREIGHT"]
    )

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/unpivot/unpivot.sql" %}

