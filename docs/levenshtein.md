

# levenshtein

Calculate the edit distance between pairwise combinations of string columns

## Parameters

| Argument |    Type     |          Description          | Is Optional |
| -------- | ----------- | ----------------------------- | ----------- |
| columns1 | column_list | first list of string columns  |             |
| column2  | column_list | second list of string columns |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.levenshtein(columns1 = ['FIRSTNAME'], columns2 = ['LASTNAME'])
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/levenshtein/levenshtein.sql" %}

