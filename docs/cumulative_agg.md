

# cumulative_agg

Row-based; Calculates a cumulative aggregate based on a relative row window.

Pass in order_by columns to create a row-based look-back or look-forward window.

Example use case: Aggregate all sales for a customer from the beginning of time until this row.


## Parameters

|   Argument   |    Type     |                                                                                                       Description                                                                                                        | Is Optional |
| ------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| aggregations | agg_dict    | Dictionary of columns and aggregate functions to apply. A column can have a list of multiple aggregates applied. One column will be created for each column:aggregate pair.                                              |             |
| order_by     | column_list | Column(s) to order rows by when calculating the agg window                                                                                                                                                               |             |
| direction    | value       | By default, the cumulative agg will calculate by looking 'backward' across all rows, according to the order_by. To override this behavior, use 'forward', and the cumulative will look at each row and all future rows.  | True        |
| group_by     | column_list | Column(s) to group by when calculating the agg window                                                                                                                                                                    | True        |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds = internet_sales.cumulative_agg(
        aggregations={
          "SALESAMOUNT": ['SUM', 'MIN', 'MAX']
        },
        group_by=['PRODUCTKEY'],
        order_by=['ORDERDATE'],
        direction='forward'
       )

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/cumulative_agg/cumulative_agg.sql" %}

