# Salesforce Lead Scoring

Salesforce tracks individuals through multiple relationship stages, including contact, lead, and opportunity. This accelerator joins each Salesforce object together, producing a single table with one row per individual so that you can quickly apply a lead scoring model or other insight.

## Parameters

|       Name        |  Type   |          Description           | Is Optional |
| ----------------- | ------- | ------------------------------ | ----------- |
| contact_table     | dataset | Salesforce contacts table      |             |
| opportunity_table | dataset | Salesforce opportunities table |             |
| account_table     | dataset | Salesforce accounts table      |             |


## Output Metrics

**Bolded** elements are indexes

### leads_target

|      Name       |  Description  |   Source   |
| --------------- | ------------- | ---------- |
| **OPTY_ID**     | It's an index | Salesforce |
| OPTY_CONTACT_ID | It's a metric | Salesforce |
| OPTY_STAGE_NAME | It's a metric | Salesforce |
| OPTY_AMOUNT     | It's a metric | Salesforce |
| QUALIFIED_LEAD  | It's a metric | Salesforce |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/lead_scoring.yml" %}