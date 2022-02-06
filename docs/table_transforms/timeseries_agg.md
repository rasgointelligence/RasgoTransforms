

# timeseries_agg

Date-based; Calculates a rolling aggregate based on a relative datetime window.

Pass in a date column, date_part and offsets to create look-back
or look-forward windows.

Example use case: Aggregate all sales for a product with order dates
within 2 months of this current order.


## Parameters

|   Argument   |    Type     |                                                                                        Description                                                                                        | Is Optional |
| ------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| aggregations | agg_dict    | Dictionary of columns and aggregate functions to apply. A column can have a list of multiple aggregates applied. One column will be created for each column:aggregate pair.               |             |
| date         | column      | Column used to calculate the time window for aggregation                                                                                                                                  |             |
| offsets      | value_list  | List of numeric values to offset the date column Negative values apply a look-back window. Positive values apply a look-forward window. One column will be created for each offset value. |             |
| date_part    | date_part   | Valid SQL date part to describe the grain of the date_offset                                                                                                                              |             |
| group_by     | column_list | Column(s) to group by when calculating the agg window                                                                                                                                     | True        |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds = internet_sales.timeseries_agg(
        aggregations={
          "SALESAMOUNT": ['SUM', 'MIN', 'MAX']
        },
        group_by=['PRODUCTKEY'],
        date='ORDERDATE'
        offsets=[-7, -14, 7, 14],
        date_part='MONTH'
       )

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/timeseries_agg/timeseries_agg.sql" %}

