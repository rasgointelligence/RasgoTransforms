

# linear_reg

Fit a simple linear regression and return the formula. Optionally, use one or more group_by columns to create a regression per unique grouping.

Currently, only supports a single independent variable.


## Parameters

| Argument |    Type     |                                                                  Description                                                                  |
| -------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| group_by | column_list | Optional, columns to group by before building the linear regression model. Use this field to create multiple models (one per unique grouping) |
| y        | column      | Dependent variable for the linear regression                                                                                                  |
| x        | column      | Independent variable for the linear regression                                                                                                |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds1 = internet_sales.aggregate(
    group_by=['PRODUCTKEY','CUSTOMERKEY'],
    aggregations={'SALESAMOUNT':['AVG'],
                'TOTALPRODUCTCOST':['AVG']})

ds2 = ds1.linear_reg(
  x = 'SALESAMOUNT_AVG',
  y = 'TOTALPRODUCTCOST_AVG')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/linear_reg/linear_reg.sql" %}

