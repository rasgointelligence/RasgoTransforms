

# rasgo_levenshtein

Computes the Levenshtein distances between two or more string columns.

## Parameters

|  Argument   |  Type   |                       Description                       |
| ----------- | ------- | ------------------------------------------------------- |
| date_column | columns | List of columns to compute the levenshtien distance for |


## Example

```py
source = rasgo.read.source_data(source.id)

t1 = source.transform(
  transform_name='rasgo_levenshtein',
  columns = ['col1', 'col2', 'col3'],

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/column_operations/rasgo_levenshtein/rasgo_levenshtein.sql" %}

