

# rasgo_find_and_replace

Replace certain values in a column/s on equality and add a specified reaplacement

## Parameters

|   Argument   |     Type     |                                                                                         Description                                                                                         |
| ------------ | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| replace_dict | replace_dict | Dictionary with keys as the column to make replacements for. Values are a nested List. Each inner list the first element would be the value to search, and the second the value to replace. |


## Example

```python
source.transform(
    transform_name=transform_name,
    replace_dict={
        "MONTH": [[4, 44], [2, 22]],   # Replace value 4 with 44 in MONTH column. Also replace 2 with 22.
        "FIPS": [['45001', '455001']]  # Replace value '45001' with '455001' in FIPS column.
    }
).preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_find_and_replace/rasgo_find_and_replace.sql" %}

