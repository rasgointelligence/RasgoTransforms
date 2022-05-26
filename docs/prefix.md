

# prefix

Add a prefix to each column name

## Parameters

|  Name  | Type  |             Description              | Is Optional |
| ------ | ----- | ------------------------------------ | ----------- |
| prefix | value | text to prefix each column name with |             |


## Example

```python
ds = rasgo.get.dataset(74)

ds2 = ds.prefix(prefix='PRODUCT')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/prefix/prefix.sql" %}

