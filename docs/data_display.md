

# data_display

Visualize a dataset flexibly, depending on axes and metrics chosen

## Parameters

|       Name        |      Type       |                                                       Description                                                       | Is Optional |
| ----------------- | --------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------- |
| x-axis            | column          | X-axis by which to view your data                                                                                       |             |
| y-axis            | column          | Y-axis by which to view your data                                                                                       | True        |
| metrics           | column_agg_list | thing                                                                                                                   |             |
| num_buckets       | value           | max number of buckets to create; defaults to 200.                                                                       | True        |
| filter_statements | string_list     | List of SQL where statements to filter the table by, i.e. 'COLUMN IS NOT NULL'                                          | True        |
| order_direction   | string          | Either ASC or DESC, depending on if you'd like to order your bar chart X-axis returned in ascending or descending order | True        |


## Example

```python
# TODO: put stuff here
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/data_display/data_display.sql" %}

