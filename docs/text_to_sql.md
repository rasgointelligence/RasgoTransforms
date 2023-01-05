

# text_to_sql

A transform that uses AI to generate a SQL statement based on user-provided text.
Describe the results you want to see, review the generated query, and make final edits to match your expectations.


## Parameters

| Name |  Type  |                                                  Description                                                   | Is Optional |
| ---- | ------ | -------------------------------------------------------------------------------------------------------------- | ----------- |
| text | string | Text description of the query you want to generate. Example: total revenue for the Southwest region last year  |             |


## Example

```python
ds = rasgo.get.dataset(fqtn='DB.SCHEMA.IOWA_LIQUOR_SALES')

ds2 = ds.text_to_sql(
  text='total bottles sold in Des Moines last year'
)
ds2.sql()
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/text_to_sql/text_to_sql.sql" %}

