

# case

This function creates a new column based on the columns provided in the `replace_dict`.

The new column generates values based on the criteria layed out in the nested list for that column. The first value is a value in the existing column for which we wish to provide a case. This value can be a column name in the data set, a fixed string, an integer, or None.

The second value is the desired output value in the new column. This can also be a column name in the data set, a fixed string, an integer, or None.

To set a default value for the new column, include a list that is one item long.

To set the output column name, include an unlisted string in the arguments.


## Parameters

|   Argument   |     Type     |                                                                                                            Description                                                                                                             |
| ------------ | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| replace_dict | replace_dict | Dictionary with keys as the column to make replacements for. Values are a nested List. In each inner list the first element would be the value to search (None means NULL), and the second the value the one to replace that with. |


## Example

```python
source = rasgo.read.source_data(source_id)

t1 = source.transform(
    transform_name='case',
    replace_dict={
        "DS_WEATHER_ICON": [[None, "EMPTY STRING"], ["cloudy", "HI"], ["DATE", "WEIRD"], ["DEFAULT VALUE"], "col_name"]
    }
)

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/case/case.sql" %}

