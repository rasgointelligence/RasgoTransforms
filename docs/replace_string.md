

# replace_string

Returns the subject with the specified pattern (or all occurrences of the pattern) either removed or replaced by a replacement string. If no matches are found, returns the original subject.


## Parameters

|  Argument   |  Type   |                                                                                       Description                                                                                        | Is Optional |
| ----------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| source_col  | column  | A string column from which to replace a pattern.                                                                                                                                         |             |
| pattern     | string  | This is the regex pattern that you want to match.                                                                                                                                        |             |
| replacement | string  | This is the value used as a replacement for the pattern.                                                                                                                                 |             |
| alias       | string  | A column name to assign the resulting column.                                                                                                                                            | True        |
| use_regex   | boolean | Use regex to find string pattern to replace defaults to 'false'; however, regex will be used if any of 'position', 'occurrence', or 'parameters' are provided, regardless of this value. | True        |
| position    | int     | Number of characters from the beginning of the string where the function starts searching for matches. Default: 1                                                                        | True        |
| occurrence  | int     | Specifies which occurrence of the pattern to replace. If 0 is specified, all occurrences are replaced. Default: 0                                                                        | True        |
| parameters  | string  | String of one or more characters that specifies the parameters used for searching for matches. Supported values: c , i , m , e , s. Default: c                                           | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.replace_string(source_col='WEATHER_DESCRIPTION', pattern='[Dd]rizzle|[Ss]prinkle', replacement='rain')
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/replace_string/replace_string.sql" %}

