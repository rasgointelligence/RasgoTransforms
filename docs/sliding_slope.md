

# sliding_slope

Calculates the linear slope on a given row, looking backwards for a user-defined window of periods.

Pass in a partition_col, an order_col, and a lookback window size. 

NOTE: Your data should be a properly formatted timeseries dataset before applying this transformation. In other words, each period should only appear once, and periods considered zero should be imputed with 0 already.
NOTE: Slope calculations are notoriously sensitive to large outliers, especially with smaller windows.

Example use case: On daily stock data, calculate SLOPE by TICKER, with a 14-period lookback window. 


## Parameters

|     Name      |  Type  |                                          Description                                          | Is Optional |
| ------------- | ------ | --------------------------------------------------------------------------------------------- | ----------- |
| partition_col | column | Grouping column to calculate the slope within.                                                |             |
| order_col     | column | Column to order rows by when calculating the agg window. Slope automatically sorts ascending. |             |
| value_col     | column | Column to calulate slope for.                                                                 |             |
| window        | int    | Number of periods to use as a lookback period, to calculate slope.                            |             |


## Example

```python
ds = rasgo.get.dataset(fqtn="RASGOCOMMUNITY.PUBLIC.ZEPL_DAILY_STOCK_FEATURES")

ds2 = ds.sliding_slope(partition_col = 'TICKER', 
              order_col = 'DATE', 
              value_col = 'CLOSE', 
              window = 14)

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/sliding_slope/snowflake/sliding_slope.sql" %}

