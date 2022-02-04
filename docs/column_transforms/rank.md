

# rank

Create a ranking of values in a column.


## Parameters

|    Argument    |    Type     |                                                                                                        Description                                                                                                        | Is Optional |
| -------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| rank_columns   | column_list | The column or expression to order (rank) by                                                                                                                                                                               |             |
| partition_by   | column_list | The column or expression to partition the window by. Accepts <None>.                                                                                                                                                      | True        |
| order          | value       | Instruction on how to order the rank_column. Accepts <None>, but defaults to ASC. ASC = Ascending DESC = Descending                                                                                                       | True        |
| rank_type      | value_list  | Type of ranking [<None> \| dense \| percent \| unique ]. Accepts <None>. <None> = ANSI SQL rank function dense = ANSI SQL dense_rank function percent = ANSI SQL percent_rank function unique = ANSI SQL row_number function | True        |
| qualify_filter | value       | A filter to apply to the ranked column. Accepts <None>.                                                                                                                                                                   | True        |


## Example

```python
#Return the 5 highest temperatures per date:
ds = rasgo.get.dataset(dataset_id)

ds2 = ds.rank(rank_columns=['DS_DAILY_HIGH_TEMP'],
      partition_by=['DATE'],
      ORDER='DESC',
      RANK_TYPE='unique',
      QUALIFY_FILTER='>=5'
})

ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rank/rank.sql" %}

