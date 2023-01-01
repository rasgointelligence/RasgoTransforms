

# summarize

Filter and then aggregate columns in a table

The filter is applied first to the table. If no filters are included, then the full table is selected.
Next, the table is aggregated.


## Parameters

|   Name    |      Type       |                                                                                                                                        Description                                                                                                                                         | Is Optional |
| --------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| filters   | filter_list     | Remove rows using filter logic on one or more columns                                                                                                                                                                                                                                      | True        |
| summarize | column_agg_list | Columns to summarize                                                                                                                                                                                                                                                                       | False       |
| group_by  | column_list     | One or more columns to group by A categorical column by which to pivot the calculated metrics. Including this argument will generate a new metric calculation for each distinct value in the group by column. If this column has more than 20 distinct values, the plot will not generate. | False       |


## Example

```python
internet_sales = rasgo.get.dataset(74)

ds1 = internet_sales.query(
  summarize={
      'SALESAMOUNT': ['COUNT', 'SUM'],
      'CUSTOMERKEY': ['COUNT']
  },
  group_by = ['PRODUCTKEY'])

ds1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/summarize/summarize.sql" %}

