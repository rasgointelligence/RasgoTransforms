

# pivot

Transpose unique values in a single column to generate multiple columns, aggregating as needed. The pivot will dynamically generate a column per unique value, or you can pass a list_of_vals with the unique values you wish to create columns for.

## Parameters

|   Argument   |    Type     |                                                         Description                                                         | Is Optional |
| ------------ | ----------- | --------------------------------------------------------------------------------------------------------------------------- | ----------- |
| dimensions   | column_list | dimension columns after the pivot runs                                                                                      |             |
| pivot_column | column      | column to pivot and aggregate                                                                                               |             |
| value_column | column      | column with row values that will become columns                                                                             |             |
| agg_method   | agg         | method of aggregation (i.e. sum, avg, min, max, etc.)                                                                       |             |
| list_of_vals | string_list | optional argument to override the dynamic lookup of all values in the value_column and only pivot a provided list of values | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.pivot(
  dimensions=['DATE'],
  pivot_column='CLOSE',
  value_column='SYMBOL',
  agg_method='AVG',
  list_of_vals=['JP','GOOG','DIS','APLE']
)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/pivot/pivot.sql" %}

