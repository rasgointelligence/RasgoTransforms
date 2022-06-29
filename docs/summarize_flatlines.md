

# summarize_flatlines

Given a dataset, searches finds "flatline" sequences of a repeated values that do not change. 

Choose a value column, a column to be used for ordering (such as a date), and a minimum cutoff for the number of repeated occurrences to consider.
 
The result is a summarized table. 


## Parameters

|       Name       |    Type     |                                                     Description                                                      | Is Optional |
| ---------------- | ----------- | -------------------------------------------------------------------------------------------------------------------- | ----------- |
| group_by         | column_list | The column(s) used to partition you data into groups. Flatlines (repeated values) will be searched within each group |             |
| value_col        | column      | The column for which to search for flatlines.                                                                        |             |
| order_col        | column      | The column used to order the rows within groups.                                                                     |             |
| min_repeat_count | int         | The minimum length of a sequence of repeated values to consider                                                      |             |


## Example

```python
ds = rasgo.get.dataset()

test = ds.apply(group_by=['TICKER','SYMBOL'],
                value_col='CLOSE',
                order_col='DATE',
                min_repeat_count=1
                )

test.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/summarize_flatlines/summarize_flatlines.sql" %}

