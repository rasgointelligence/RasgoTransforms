

# lead

Lead shifts your features on a partition index, creating a look-forward feature offset by an amount. Lead supports generating multiple leads in one transform by generating each unique combination of columns and amounts from your inputs.

## Parameters

|   Name    |    Type     |                     Description                     | Is Optional |
| --------- | ----------- | --------------------------------------------------- | ----------- |
| columns   | column_list | names of column(s) you want to lead                 |             |
| amounts   | int_list    | Magnitude of amounts you want to use for the lead.  |             |
| partition | column_list | name of column(s) to partition by for the lead      | True        |
| order_by  | column_list | name of column(s) to order by in the final data set | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.lead(columns=['OPEN', 'CLOSE'], amounts=[1,2,3,7], order_by=['DATE, 'TICKER'], partition=['TICKER'])
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/lead/lead.sql" %}

