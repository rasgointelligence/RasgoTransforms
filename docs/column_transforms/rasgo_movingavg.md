

# rasgo_movingavg

generates moving averages per column and per window size

## Parameters

|   Argument    |    Type     |                                Description                                 |
| ------------- | ----------- | -------------------------------------------------------------------------- |
| input_columns | column_list | names of column(s) you want to moving average                              |
| window_sizes  | value_list  | the integer values for window sizes you want to use in your moving average |
| date_dim      | column      | the date value to order by                                                 |
| dimension     | column      | the dimension column to partition by                                       |


## Example

```python
stock_source = rasgo.get.data_source(id=1151)

t1 = stock_source.transform(
  transform_name='rasgo_movingavg',
  date_dim='DATE',
  dimension='TICKER',
  window_sizes=[3,7,14,21],
  input_columns=['OPEN','CLOSE','HIGH','LOW'])

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_movingavg/rasgo_movingavg.sql" %}

