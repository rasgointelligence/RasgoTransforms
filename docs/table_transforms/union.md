

# union

Performs a SQL UNION or UNION ALL for the parent dataset, and another dataset. Operation will only merge columns with matching columns names in both datasets and drop all other columns. Column data type validation does not happen.

## Parameters

|  Argument  |  Type   |                                                                 Description                                                                  | Is Optional |
| ---------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| dataset2   | table   | Dataset to Union/Union All with main dataset                                                                                                 |             |
| keep_dupes | boolean | Set to True to performn a UNION ALL between the two tables, which keeps rows that are duplicated. Set to False to eliminate duplicate rows.  | True        |


## Example

```python
d1 = rasgo.get.dataset(dataset_id)
d2 = rasgo.get.dataset(dataset_id_2)

ds2 = d1.transform.union(
    dataset2=d2,
    keep_dupes=True
)

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/union/union.sql" %}

