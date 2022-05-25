# Business to Business Sales Funnel

A sales funnel represents the journey a prospective customer takes on their way to a purchase. In business-to-business sales, the customer is the business or organization that will ultimately purchase the product or service, and engage in a business relationship with the vendor.

## Parameters

|       Name        | Type |         Description          | Is Optional |
| ----------------- | ---- | ---------------------------- | ----------- |
| opportunity_table |      | Salesforce opportunity table |             |
| lead_table        |      | Salesforce lead table        |             |


## Output Metrics

### daily_sales_funnel_metrics

|    Name    | Index |                               Description                               |   Source   |
| ---------- | ----- | ----------------------------------------------------------------------- | ---------- |
| DATE       |       | Date on which the stage occured                                         | Salesforce |
| WEEK       |       | Week in which the stage occured                                         | Salesforce |
| MONTH      |       | Month in which the stage occured                                        | Salesforce |
| QUARTER    |       | QUARTER in which the stage occured                                      | Salesforce |
| MQL        |       | Number of MQLs recorded on this date                                    | Salesforce |
| SAL        |       | Number of SALs recorded on this date                                    | Salesforce |
| SQL        |       | Number of SQLs recorded on this date                                    | Salesforce |
| SQO        |       | Number of SQOs recorded on this date                                    | Salesforce |
| VALIDATE   |       | Number of opportunities entering validation stage recorded on this date | Salesforce |
| CLOSED_WON |       | Number of opportunities that closed successfully recorded on this date  | Salesforce |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/b2b_funnel.yml" %}