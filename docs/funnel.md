

# funnel

If you have numeric columns representing the number of times a particular outcome occurs in your data, this transform creates a ready-to-visualize dataset of the survival rate in the funnel

## Parameters

|   Argument    |    Type     |                         Description                          | Is Optional |
| ------------- | ----------- | ------------------------------------------------------------ | ----------- |
| stage_columns | column_list | Ordered list of columns, from highest in hierarchy to lowest |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.funnel(stage_columns=["TOTAL_IMPRESSIONS", "TOTAL_EMAILS_SENT", "TOTAL_WEBTRAFFIC_USERS", "TOTAL_LEADS_CREATED", "TOTAL_DEALS_CLOSED"])
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/funnel/funnel.sql" %}

