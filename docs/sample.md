

# sample

Take a sample of a dataset using a specific number of rows or a probability that each row will be selected

## Parameters

| Argument | Type  |                                                                           Description                                                                            | Is Optional |
| -------- | ----- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| num_rows | value | To sample using a probability of selecting each row, your num_rows should be a decimal less than 1. Otherwise, pass an integer value for number of rows to keep. |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.sample(sample_amount=1000)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/row_transforms/sample/sample.sql" %}

