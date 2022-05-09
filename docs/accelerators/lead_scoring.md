# Salesforce Lead Scoring

Salesforce tracks individuals through multiple relationship stages, including contact, lead, and opportunity. This accelerator joins each Salesforce object together, producing a single table with one row per individual so that you can quickly apply a lead scoring model or other insight.

## Parameters

|       Name        |  Type   |          Description           | Is Optional |
| ----------------- | ------- | ------------------------------ | ----------- |
| contact_table     | dataset | Salesforce contacts table      |             |
| opportunity_table | dataset | Salesforce opportunities table |             |
| account_table     | dataset | Salesforce accounts table      |             |


## Output Metrics

### leads_target

|           Name           | Index |                           Description                           |   Source   |
| ------------------------ | ----- | --------------------------------------------------------------- | ---------- |
| ACCOUNT_ID               |       | Salesforce Account ID                                           | Salesforce |
| NAME                     |       | Contact's name, from the contacts table                         | Salesforce |
| EMAIL                    | True  | Contact's email, from the contacts table                        | Salesforce |
| TITLE                    |       | Contact's job title, from the contacts table                    | Salesforce |
| LEAD_SOURCE              |       | Channel where the contact's info came from                      | Salesforce |
| CREATED_DATE             |       | Date when the Contact was created                               | Salesforce |
| INITIAL_CONTACT_METHOD_C |       | First way we interacted with the Contact                        | Salesforce |
| INITIAL_SOURCE_DETAIL_C  |       | More detail on the channel where we got the contact's info from | Salesforce |
| MQL_DATE_C               |       | Date on which the lead became qualified by marketing            | Salesforce |
| SALES_ACCEPTED_DATE_C    |       | Date on which Sales accepted the lead                           | Salesforce |
| ACNT_ID                  |       | Salesforce account ID                                           | Salesforce |
| ACNT_NAME                |       | Salesforce account name                                         | Salesforce |
| ACNT_ACCOUNT_SOURCE      |       | Channel that the account first came from                        | Salesforce |
| OPTY_ID                  |       | Salesforce Opportunity ID                                       | Salesforce |
| OPTY_CONTACT_ID          |       | Salesforce Contact ID                                           | Salesforce |
| OPTY_STAGE_NAME          |       | The stage of the opportunity                                    | Salesforce |
| OPTY_AMOUNT              |       | The dollar amount of the opportunity                            | Salesforce |
| QUALIFIED_LEAD           |       | Whether the lead is qualified or not                            | Salesforce |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/lead_scoring.yml" %}