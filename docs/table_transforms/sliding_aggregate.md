

# sliding_aggregate

Calculates a sliding aggregate of a column over one or more row offset windows,
producing a column per window.


## Parameters

|   Argument   |    Type     |                                                                                                              Description                                                                                                              | Is Optional |
| ------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| aggregations | dict        | Dictionary of columns and aggregate functions to apply. A column can have a list of multiple aggregates applied. One column will be created for each column:aggregate pair.                                                           |             |
| windows      | value_list  | List of numeric offset values to apply when calculating the row offset window.  Positive values apply a look-back window. Negative values apply a look-forward window. One column will be created for each window value in the list.  |             |
| group_by     | column_list | Column(s) to group by when calculating the agg window                                                                                                                                                                                 |             |
| order_by     | column_list | Column(s) to order by when calculating the agg window                                                                                                                                                                                 |             |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds = internet_sales.rolling_aggregate(
        aggregations={
          "SALESAMOUNT": [SUM, MIN, MAX],
          "ITEMQUANTITY": [SUM, MIN, MAX],
        },
        windows=[1, 7, 14],
        group_by=['PRODUCTKEY']
        order_by='ORDERDATE'
     )

ds.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/sliding_aggregate/sliding_aggregate.sql" %}

