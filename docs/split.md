

# split

Takes a delimiter and target column, splitting the column values by the delimiter into multiple columns.


## Parameters

|    Name     |    Type     |                                                                                                                                                                               Description                                                                                                                                                                                | Is Optional |
| ----------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| target_col  | column      | A string column to split into multiple columns.                                                                                                                                                                                                                                                                                                                          |             |
| sep         | string      | This is the delimiter used to split the string.                                                                                                                                                                                                                                                                                                                          |             |
| output_cols | string_list | The labels for the new columns. This transformation will create as many columns as are in this list. If there are more delimiters than output columns, the trailing value with excess delimiters will all be added to the last column. If there are more output columns than delimiters, the first columns will take the existing values and the remainder will be null. |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.split(target_col='PRODUCTKEY', sep='-', output_cols=['KEY_PREFIX', 'KEY_ROOT', 'KEY_SUFFIX'])
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/split/split.sql" %}

