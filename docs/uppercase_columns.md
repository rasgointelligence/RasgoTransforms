

# rename

Rename columns by converting all names to uppercase and removing non-SQL safe characters.


## Parameters

| Name | Type |                Description                 | Is Optional |
| ---- | ---- | ------------------------------------------ | ----------- |
| none | none | this transform does not take any arguments |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.uppercase_columns()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/uppercase_columns/uppercase_columns.sql" %}

