

# rolling_agg

Row-based; Calculates a rolling aggregate based on a relative row window.

Pass in order_by columns and offsets to create a row-based look-back or look-forward windows.

Example use case: Aggregate the last 10 sales for a customer regardless of when they occurred.


## Parameters

|   Argument   |    Type     |                                                                                         Description                                                                                         | Is Optional |
| ------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| aggregations | agg_dict    | Dictionary of columns and aggregate functions to apply. A column can have a list of multiple aggregates applied. One column will be created for each column:aggregate pair.                 |             |
| order_by     | column_list | Column(s) to order rows by when calculating the agg window                                                                                                                                  |             |
| offsets      | int_list    | List of numeric values to offset the date column. Positive values apply a look-back window. Negative values apply a look-forward window. One column will be created for each offset value.  |             |
| group_by     | column_list | Column(s) to group by when calculating the agg window                                                                                                                                       | True        |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds = internet_sales.rolling_agg(
      aggregations={
        'SALESAMOUNT':['MAX', 'MIN', 'SUM']
      },
      order_by=['ORDERDATE'],
      offsets=[-7, 7, 14],
      group_by=['PRODUCTKEY'],
  )

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/rolling_agg/rolling_agg.sql" %}

