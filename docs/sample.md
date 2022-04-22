

# sample

Take a sample of a dataset using a specific number of rows or a probability that each row will be selected

## Parameters

|     Argument      |    Type     |                                                                           Description                                                                            | Is Optional |
| ----------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| num_rows          | value       | To sample using a probability of selecting each row, your num_rows should be a decimal less than 1. Otherwise, pass an integer value for number of rows to keep. |             |
| filter_statements | string_list | List of where statements filter the table by. Ex. ["<col_name> = 'string'", "<col_name> IS NOT NULL"]                                                            | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.sample(num_rows=1000)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/sample/sample.sql" %}

