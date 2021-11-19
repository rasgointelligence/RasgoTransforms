

# lagagg

Lag Agg uses a reference column to aggregate and join with a base dataset

## Parameters

|   Argument    |    Type     |                     Description                      |
| ------------- | ----------- | ---------------------------------------------------- |
| columns       | column_list | names of column(s) you want to lagagg                |
| windows       | value_list  | Magnitude of windows you want to use for the lagagg. |
| date          | column      | name of column with base dataset date                |
| event_date    | column      | date column in the event dataset                     |
| agg_type      | agg         | aggregation method to use on the lag window          |
| event_dataset | source      | data source with the event data                      |


## Example

```python
source = rasgo.read.source_data(source.id)
event_source = rasgo.read.source_data(101)

t1 = my_source.transform(
    transform_name='lagagg',
    columns=['CLOSE'],
    windows=[7,14,30,60],
    date='DATE',
    event_date='EventDate',
    agg_type='SUM',
    event_dataset=event_source.id
    )

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/lag_agg/lag_agg.sql" %}

