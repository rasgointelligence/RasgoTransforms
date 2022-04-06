

# sample_class

Sample n rows for each value of a column

## Parameters

|  Argument  |  Type  |                       Description                        | Is Optional |
| ---------- | ------ | -------------------------------------------------------- | ----------- |
| sample_col | column | The column for which you want to sample                  |             |
| sample     | dict   | Value of column as a key, n rows to be sampled as values |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.sample_class(sample_col='BINARY_TARGET_COLUMNNAME', sample={'1':15000, '0':60000})
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/sample_class/sample_class.sql" %}

