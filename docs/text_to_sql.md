

# text_to_sql

## Text to SQL, powered by OpenAI.
### Required Inputs
- Text: a prompt describing the SQL query that you want OpenAI to generate for you. Add as much context as possible to help OpenAI generate a useful query. Avoid using relative date terms like "last year" because OpenAI doesn't have any knowledge past 2021.


## Parameters

| Name |    Type     |                                                 Description                                                  | Is Optional |
| ---- | ----------- | ------------------------------------------------------------------------------------------------------------ | ----------- |
| text | string-long | Text description of the query you want to generate. Example: total revenue for the Southwest region in 2021  |             |


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

