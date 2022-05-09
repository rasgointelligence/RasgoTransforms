

# dropna

Remove missing values

## Parameters

|  Name  |    Type     |                                                                                  Description                                                                                   | Is Optional |
| ------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| how    | value       | Method to determine if record is removed, 'any' removes each record with at least one missing value, 'all' removes records only when all values are missing (default = 'any'). | True        |
| subset | column_list | List of columns to check for missing values. All columns are checked if not defined.                                                                                           | True        |
| thresh | int         | (Optional) Acts like all, but only requires this number of values to be null to remove a record instead of all.                                                                | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.dropna(how='all', subset=['ORDERS', 'SALES'])
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/dropna/dropna.sql" %}

