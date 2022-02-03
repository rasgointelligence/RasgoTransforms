

# rolling

Calculates a cumulative aggregate of a column over one or more windows,
producing a column per window.


## Parameters

|   Argument   |    Type     |                                                                                 Description                                                                                  | Is Optional |
| ------------ | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| aggregations | dict        | Dictionary of columns and aggregate functions to apply. A column can have a list of multiple aggregates applied. One column will be created for each column:aggregate pair.  |             |
| group_by     | column_list | Column(s) to group by when calculating the agg window                                                                                                                        |             |
| order_by     | column      | Column to order by when calculating the agg window                                                                                                                           |             |
| date_offset  | value       | Numeric value to offset the date field in the order_by clause Negative values apply a look-back window. Positive values apply a look-forward window.                         | True        |
| date_part    | value       | Valid SQL date part to describe the grain of the date_offset                                                                                                                 | True        |


## Example

```python
internet_sales = rasgo.get.dataset(74)

# Usage 1: simple unbound rolling window
# This will aggregate all sales & qty for a product with an order date <= the current record
ds = internet_sales.rolling_aggregate(
        aggregations={
          "SALESAMOUNT": ['SUM', 'MIN', 'MAX'],
          "ITEMQUANTITY": ['SUM', 'MIN', 'MAX'],
        },
        group_by=['PRODUCTKEY'],
        order_by='ORDERDATE'
     )

ds.preview()


# Usage 2: 2 month time-offset window
# This will aggregate all sales for a product with order dates from 2 month ago
# up to the current record's orderdate
ds = internet_sales.rolling_aggregate(
        aggregations={
          "SALESAMOUNT": ['SUM', 'MIN', 'MAX']
        },
        group_by=['PRODUCTKEY'],
        date_column='ORDERDATE'
        date_offset=-2,
        date_part='MONTH'
     )

ds.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/rolling_aggregate/rolling_aggregate.sql" %}

