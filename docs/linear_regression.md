

# linear_regression

Fit a simple linear regression and return the formula. Optionally, use one or more group_by columns to create a regression per unique grouping.

Currently, only supports a single independent variable.


## Parameters

|   Name   |    Type     |                                                             Description                                                             | Is Optional |
| -------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| group_by | column_list | Columns to group by before building the linear regression model. Use this field to create multiple models (one per unique grouping) | True        |
| y        | column      | Dependent variable for the linear regression                                                                                        |             |
| x        | column      | Independent variable for the linear regression                                                                                      |             |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds1 = internet_sales.aggregate(
    group_by=['PRODUCTKEY','CUSTOMERKEY'],
    aggregations={'SALESAMOUNT':['AVG'],
                'TOTALPRODUCTCOST':['AVG']})

ds2 = ds1.linear_regression(
  x = 'SALESAMOUNT_AVG',
  y = 'TOTALPRODUCTCOST_AVG')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/linear_regression/linear_regression.sql" %}

