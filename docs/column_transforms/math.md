

# math

Calculate one or more new columns using math functions.

Examples of Valid Functions:
  - [Basic Arithmetic](https://docs.snowflake.com/en/sql-reference/operators-arithmetic.html#list-of-arithmetic-operators)
  - [Numeric Functions](https://docs.snowflake.com/en/sql-reference/functions-numeric.html)


## Parameters

| Argument |    Type    |                                               Description                                               | Is Optional |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------- | ----------- |
| math_ops | math_list  | List of math operations to generate new columns. For example, ["AGE_COLUMN + 5", "WEIGHT_COLUMN / 100"] |             |
| names    | value_list | To alias the new columns, provide a list of column names matching the number of math operations.        | True        |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds2 = internet_sales.math(
    math_ops=['SALESAMOUNT * 10', 'SALESAMOUNT - TAXAMT'],
    names=['Sales10', 'SalesNet'])

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/math/math.sql" %}

