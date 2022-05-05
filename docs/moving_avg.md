

# moving_avg

generates moving averages per column and per window size

## Parameters

|     Name      |    Type     |                                Description                                 | Is Optional |
| ------------- | ----------- | -------------------------------------------------------------------------- | ----------- |
| input_columns | column_list | names of column(s) you want to moving average                              |             |
| window_sizes  | int_list    | the integer values for window sizes you want to use in your moving average |             |
| order_by      | column_list | columns to order by, typically the date index of the table                 |             |
| partition     | column_list | columns to partition the moving average by                                 |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.moving_avg(input_columns=['OPEN','CLOSE','HIGH','LOW'], window_sizes=[1,2,3,7], order_by=['DATE, 'TICKER'], partition=['TICKER'])
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/moving_avg/moving_avg.sql" %}

