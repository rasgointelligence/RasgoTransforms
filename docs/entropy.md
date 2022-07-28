

# entropy

Entropy is a way to calculate the amount of "disorder" in a non-numeric column. Lower entropy indicates less disorder, while higher entropy indicates more.

The calculation for Shannon's entropy is: H = -Sum[ P(xi) * log2( P(xi)) ]


## Parameters

|   Name   |    Type     |                      Description                      | Is Optional |
| -------- | ----------- | ----------------------------------------------------- | ----------- |
| group_by | column_list | Columns to group by                                   |             |
| columns  | column_list | Columns to calculate entropy on. Must be non-numeric. |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.entropy(group_by=['FIPS'], columns=['NAME', 'ADDRESS'])
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/entropy/entropy.sql" %}

