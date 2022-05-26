# Omni-channel performance

Omni-channel performance tracks leads through a traditional sales funnel: from awareness via marketing at top of funnel, to marketing qualified lead, to sales qualified lead, and finally to closed as a won opportunity. The data sources necessary to generate this accelerator are Google Analytics, Hubspot, and Salesforce.

## Parameters

|        Name         |  Type   |                  Description                  | Is Optional |
| ------------------- | ------- | --------------------------------------------- | ----------- |
| contact_table       | dataset | Salesforce contacts table                     |             |
| opportunity_table   | dataset | Salesforce opportunities table                |             |
| account_table       | dataset | Salesforce accounts table                     |             |
| lead_table          | dataset | Salesforce leads table                        |             |
| daily_traffic_table | dataset | Google Analytics daily traffic overview table |             |
| email_event_table   | dataset | Hubspot email event table                     |             |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/omni_channel_performance.yml" %}