

# clean

Cast data types, rename or drop columns, impute missing values, and filter values in a dataset

## Parameters

|  Name   |    Type    |                                                                                                                                                                          Description                                                                                                                                                                          | Is Optional |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| columns | clean_dict | Dictionary with keys as column names to clean, values are all optional: type - the dtype to cast the values to, name - the new name for a column, impute - an imputation strategy or value for replacing null values ('mean', 'median', 'mode', <value>), filter - a filter statement to filter the output table, drop - drops column from the output if true |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.clean(
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
    }
)

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/clean/clean.sql" %}

