

# latest

Impute missing values in ALL columns with the latest value seen in rows prior

## Parameters

| Argument |    Type     |                                               Description                                                | Is Optional |
| -------- | ----------- | -------------------------------------------------------------------------------------------------------- | ----------- |
| group_by | column_list | List of columns to perform the imputation "within"                                                       |             |
| order_by | column_list | List of columns to sort ascending, in order to find the last known value for imputation                  |             |
| nulls    | string      | Pass either 'ignore' or 'respect' to determine whether nulls should be ignored or not during imputation. |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.latest(
  group_by=['FIPS'],
  order_by=['DATE'],
  nulls='ignore')

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/latest/latest.sql" %}

