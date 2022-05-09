

# funnel

Creates a funnel visualization-ready dataset from numeric columns (e.g., ["Number of leads", "Number of contacts", "Number of deals closed"]) representing a hierarchy with summed incidence rates

## Parameters

|     Name      |    Type     |                                                                                      Description                                                                                       | Is Optional |
| ------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| stage_columns | column_list | List of columns to include in the funnel dataset, in order of hierarchy from highest stage to lowest stage (e.g., ["Number of leads", "Number of contacts", "Number of deals closed"]) |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.funnel(stage_columns=["TOTAL_IMPRESSIONS", "TOTAL_EMAILS_SENT", "TOTAL_WEBTRAFFIC_USERS", "TOTAL_LEADS_CREATED", "TOTAL_DEALS_CLOSED"])
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/funnel/funnel.sql" %}

