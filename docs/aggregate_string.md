

# aggregate_string

Aggregate strings across rows by concatenating them together, and grouping by other columns.

Uses a text separator to aggregate the string values together, and returns a single column where the rows are the aggregated strings.


## Parameters

|    Name     |    Type     |                                                         Description                                                          | Is Optional |
| ----------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------- | ----------- |
| agg_columns | column_list | Columns with string values to aggregate                                                                                      |             |
| sep         | value       | Text separator to use when aggregating the strings, i.e. ', '.                                                               |             |
| group_by    | column_list | Columns to group by when applying the aggregation.                                                                           |             |
| distinct    | boolean     | If you want to collapse multiple rows of the same string value into a single distinct value, use TRUE. Otherwise, use FALSE. |             |
| order       | value       | ASC or DESC, to set the alphabetical order of the agg_column when aggregating it                                             |             |


## Example

```python
product = rasgo.get.dataset(75)

ds2 = product.aggregate_string(group_by=['PRODUCTLINE'],
                agg_columns=['PRODUCTKEY', 'ENGLISHPRODUCTNAME'],
                sep=', ',
                distinct='FALSE',
                order='ASC')
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/aggregate_string/aggregate_string.sql" %}

