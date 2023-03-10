

# comparison

## Comparison that calculates the same metrics across two different groups of rows from the same table.

### Required Inputs
- Comparison Values: Columns with aggregation methods to use as metrics for the comparison between groups
- Group A Filters: Filters that define the rows that belong to group A
- Group B Filters: Filters that define the rows that belong to group B

### Optional Inputs
- Comparison Dimensions: Dimensions to compare the groups by
- Shared Filters: Filter the whole table before you run the comparison

### Notes
- When choosing your comparison dimensions, try to pick columns that apply to both of your groups


## Parameters

|         Name          |           Type            |                                             Description                                             | Is Optional |
| --------------------- | ------------------------- | --------------------------------------------------------------------------------------------------- | ----------- |
| comparison_values     | column_agg_list           | Columns to aggregate to create metrics for the comparison                                           |             |
| group_a_filters       | filter_list               | Filters that define Group A for the comparison                                                      |             |
| group_b_filters       | filter_list               | Filters that define Group B for the comparison                                                      |             |
| comparison_dimensions | column_or_expression_list | Dimensions to group by before comparing groups. Supports calculated fields via valid SQL functions. | True        |
| shared_filters        | filter_list               | Filters to apply to the underlying data before segmenting into groups                               | True        |


## Example

```python

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/comparison/snowflake/comparison.sql" %}

