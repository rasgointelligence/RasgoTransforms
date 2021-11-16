

# levenshtein

Calculate the edit distance between pairwise combinations of string columns

## Parameters

| Argument |    Type     |          Description          |
| -------- | ----------- | ----------------------------- |
| columns1 | column_list | first list of string columns  |
| column2  | column_list | second list of string columns |


## Example

```python
source = rasgo.read.source_data(source.id)

t1 = source.transform(
  transform_name='levenshtein',
  columns1 = ['FIRSTNAME'],
  columns2 = ['LASTNAME']
)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/levenshtein/levenshtein.sql" %}

