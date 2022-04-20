

# replace_string

This function replaces text in a column according to the given pattern.


## Parameters

|  Argument   |  Type  |                       Description                        | Is Optional |
| ----------- | ------ | -------------------------------------------------------- | ----------- |
| source_col  | column | A string column from which to replace a pattern.         |             |
| pattern     | string | This is the substring that you want to replace.          |             |
| replacement | string | This is the value used as a replacement for the pattern. |             |
| target_col  | column | A column name to assign the resulting column.            | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.replace_string(source_col='WEATHER_DESCRIPTION', pattern='drizzle', replacement='rain')
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/replace_string/replace_string.sql" %}

