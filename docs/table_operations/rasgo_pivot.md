

# rasgo_pivot

Transpose unique values in a single column to generate multiple columns, aggregating as needed. The pivot will dynamically generate a column per unique value, or you can pass a list_of_vals with the unique values you wish to create columsn for.

## Parameters

|   Argument   |    Type     |                                                         Description                                                         |
| ------------ | ----------- | --------------------------------------------------------------------------------------------------------------------------- |
| dimensions   | column_list | dimension columns after the pivot runs                                                                                      |
| pivot_column | column      | column to pivot and aggregate                                                                                               |
| value_column | column      | column with row values that will become columns                                                                             |
| agg_method   | string      | method of aggregation (i.e. sum, avg, min, max, etc.)                                                                       |
| list_of_vals | string_list | optional argument to override the dynamic lookup of all values in the value_column and only pivot a provided list of values |


## Example

```py
stock_source = rasgo.get.data_source(id=1151)

stock_source.transform(
  transform_name='rasgo_pivot',
  dimensions=['DATE'],
  pivot_column='CLOSE',
  value_column='SYMBOL',
  agg_method='AVG',
  list_of_vals=['JP','GOOG','DIS','APLE']
).preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/table_operations/rasgo_pivot/rasgo_pivot.sql" %}

