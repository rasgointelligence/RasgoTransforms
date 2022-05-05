

# multi_join

Union n number of datasets with the 'base' dataset, using a common list of columns between each dataset, and selecting them in order.


## Parameters

|     Name      |    Type     |                                                 Description                                                  | Is Optional |
| ------------- | ----------- | ------------------------------------------------------------------------------------------------------------ | ----------- |
| union_tables  | table_list  | Datasets to union with the source_table                                                                      |             |
| union_columns | column_list | Columns to union on. Can be one or more columns but must be named the same thing between all union datasets. |             |


## Example

```python
d1 = rasgo.get.dataset(dataset_id)
d2 = rasgo.get.dataset(dataset_id_2)
d3 = rasgo.get.dataset(dataset_id_3)

ds2 = d1.multi_union(
    union_tables=[d2, d3],
    union_columns=['DATE', 'ZIPCODE', 'DAILY_HIGH_TEMP', 'DAILY_LOW_TEMP']
)

ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/multi_union/multi_union.sql" %}

