

# clean

Cast data types, rename or drop columns, impute missing values, and filter values in a dataset

## Parameters

|   Argument   |    Type    |                                                                                                                                                         Description                                                                                                                                                         | Is Optional |
| ------------ | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| columns      | clean_dict | Dictionary with keys as column names to clean, values are all optional, including type - the dtype to cast the values to, name - the new name for a column, impute - an imputation strategy or value for replacing null values ('mean', 'median', 'mode', <value>), filter - a filter statement to filter the output table. |             |
| drop_columns | boolean    | If True/set will drop all of the columns not included in the 'columns' argument.                                                                                                                                                                                                                                            | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.impute(
    columns={
        'GLD_ADJUSTED_CLOSE': {
            'type': 'FLOAT',
            'name': 'GLD',
            'impute': 'mean',
            'filter': "> 100",
        },
        'GLTR_ADJUSTED_CLOSE': {
            'type': 'FLOAT',
            'name': 'GLTR',
            'impute': 'min',
            'filter': "> 10",
        },
        'DATE': {
            'type': 'string'
        }
    },
    drop_columns=True
)

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/clean/clean.sql" %}

