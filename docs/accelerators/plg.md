# Product-Led Growth Funnel

The product-led growth funnel tracks users through a common Software as a Service (SaaS) funnel: from awareness via marketing at top of funnel, to free product user, to qualified lead for an enterprise sales motion, to closed won. The data sources necessary to generate this accelerator are Google Analytics, Heap, and Salesforce.

## Parameters

|        Name         |  Type   |                  Description                  | Is Optional |
| ------------------- | ------- | --------------------------------------------- | ----------- |
| contact_table       | dataset | Salesforce contacts table                     |             |
| opportunity_table   | dataset | Salesforce opportunities table                |             |
| account_table       | dataset | Salesforce accounts table                     |             |
| lead_table          | dataset | Salesforce leads table                        |             |
| daily_traffic_table | dataset | Google Analytics daily traffic overview table |             |
| heap_users_table    | dataset | Heap Users Table                              |             |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/plg.yml" %}