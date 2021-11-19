

# find_and_replace

Replace certain values in a column/s on equality and add a specified reaplacement

## Parameters

|   Argument   |     Type     |                                                                                                            Description                                                                                                             |
| ------------ | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| replace_dict | replace_dict | Dictionary with keys as the column to make replacements for. Values are a nested List. In each inner list the first element would be the value to search (None means NULL), and the second the value the one to replace that with. |


## Example

```python
source = rasgo.read.source_data(source_id)

source.transform(
    transform_name='find_and_replace',
    replace_dict={
        "MONTH": [[2, 22], [None, 44]],   # Replace 2 with 22 in MONTH column. Also replace value NULL with 44 
        "FIPS": [['45001', '455001']]  # Replace value '45001' with '455001' in FIPS column.
    }
).preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/find_and_replace/find_and_replace.sql" %}

