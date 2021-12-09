

# union

Performs a SQL UNION or UNION ALL for the parent source, and another source by entering the source_id. Operation will only merge columns with matching columns names in both datasets and drop all other columns. Column data type validation does not happen.

## Parameters

| Argument  |  Type   |                                Description                                |
| --------- | ------- | ------------------------------------------------------------------------- |
| source    | table   | Dataset to Union/Union All with main source                               |
| union_all | boolean | Set to True to performn a UNION ALL instead UNION between the two sources |


## Example

```python
ds = rasgo.get.dataset(dataset.id)
ds_2 = rasgo.get.dataset(dataset_2.id)
  
t1 = source.transform(
  transform_name='union',
  source = ds_2,
  union_all = True
)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/union/union.sql" %}

