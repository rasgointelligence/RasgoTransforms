

# rasgo_one_hot_encode

One hot encode a column and drop it from the dataset. Create a null value flag for the column too.

## Parameters

| Argument |  Type  |          Description          |
| -------- | ------ | ----------------------------- |
| column   | column | Column name to one hot encode |


## Example

```python
source.transform(
  transform_name='rasgo_one_hot_encode',
  column="MONTH"
).preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_one_hot_encode/rasgo_one_hot_encode.sql" %}

