

# suffix

Add a suffix to each column name

## Parameters

|  Name  | Type  |             Description              | Is Optional |
| ------ | ----- | ------------------------------------ | ----------- |
| prefix | value | text to suffix each column name with |             |


## Example

```python
ds = rasgo.get.dataset(74)

ds2 = ds.suffix(suffix='PRODUCT')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/suffix/suffix.sql" %}

