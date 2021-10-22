

# union

Performs a SQL UNION for the parent source, and another source by entering the source_id. Operation will only merge columns with matching columns names in both datasets and drop all other columns. Column data tpe validation does not happen.

## Parameters

| Argument  |  Type   |                                Description                                |
| --------- | ------- | ------------------------------------------------------------------------- |
| source_id | source  | Source id of the source to Union/Union All with main soure                |
| union_all | boolean | Set to True to performn a UNION ALL instead UNION between the two sources |


## Example

```py
source = rasgo.read.source_data(source.id)
  
t1 = source.transform(
  transform_name='rasgo_union',
  source_id = 22,
  union_all = True
)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/table_operations/rasgo_union/rasgo_union.sql" %}

