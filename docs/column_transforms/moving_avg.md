

# moving_avg

generates moving averages per column and per window size

## Parameters

|   Argument    |    Type     |                                Description                                 |
| ------------- | ----------- | -------------------------------------------------------------------------- |
| input_columns | column_list | names of column(s) you want to moving average                              |
| window_sizes  | value_list  | the integer values for window sizes you want to use in your moving average |
| order_by      | column      | the date or ordinal value to order by                                      |
| partition     | column_list | the dimension column to partition by                                       |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.moving_avg(input_columns=['OPEN','CLOSE','HIGH','LOW'], window_sizes=[1,2,3,7], order_by=['DATE, 'TICKER'], partition=['TICKER'])
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/moving_avg/moving_avg.sql" %}

