# Salesforce Lead Scoring

Salesforce tracks individuals through multiple relationship stages, including contact, lead, and opportunity, and ties this to the account. This accelerator joins each Salesforce object together, producing a single table with one row per lead, and determines if the lead is closed won or lost so that you can quickly apply a lead scoring model or other insight.

## Parameters

|        Name         | Type |          Description           | Is Optional |
| ------------------- | ---- | ------------------------------ | ----------- |
| accounts_table      |      | Salesforce accounts table      |             |
| opportunities_table |      | Salesforce opportunities table |             |
| leads_table         |      | Salesforce leads table         |             |
| contacts_table      |      | Salesforce contacts table      |             |


## Output Metrics

### lead_scoring_modeling_data

|           Name           | Index |                                              Description                                              |   Source   |
| ------------------------ | ----- | ----------------------------------------------------------------------------------------------------- | ---------- |
| ACCOUNT_ID               |       | Salesforce Account ID                                                                                 | Salesforce |
| AMOUNT                   |       | Forecast or actual amount of subscription from the opportunities table                                | Salesforce |
| ANNUAL_REVENUE           |       | Annual revenue from the accounts table                                                                | Salesforce |
| ASSISTANT_NAME           |       | Contact's assistant's name from the contacts table                                                    | Salesforce |
| ASSISTANT_PHONE          |       | Contact's assistant's phone from the contacts table                                                   | Salesforce |
| BILLING_COUNTRY          |       | Billing country from the accounts table                                                               | Salesforce |
| BILLING_POSTAL_CODE      |       | Billing postal code from the accounts table                                                           | Salesforce |
| BILLING_STATE            |       | Billing state from the accounts table                                                                 | Salesforce |
| BUSINESS_CASE_C          |       | Described business case from the opportunties table                                                   | Salesforce |
| BUSINESS_OUTCOME_C       |       | Desired business outcome from the opportunties table                                                  | Salesforce |
| CHALLENGES_C             |       | Described challenges from the opportunties table                                                      | Salesforce |
| CLOSED_WON               |       | Target generated from the opportunites table. Does this lead convert to being a customer              | Salesforce |
| COMPANY_NAME             |       | Company name from the account table                                                                   | Salesforce |
| CREATED_DATE             |       | Date when the contact was created from the contacts table                                             | Salesforce |
| DEPARTMENT               |       | Contact's department from the contact table                                                           | Salesforce |
| DESCRIPTION              |       | Contact's description from the contacts table                                                         | Salesforce |
| ECONOMIC_BUYER_C         |       | Economic buyer from the opportunities table                                                           | Salesforce |
| EMAIL                    |       | Contact's email from the contacts table                                                               | Salesforce |
| FISCAL_QUARTER           |       | Fiscal quarter opportuntiy expected to close from the opportunties table                              | Salesforce |
| FISCAL_YEAR              |       | Fiscal year opportuntiy expected to close from the opportunties table                                 | Salesforce |
| ID                       |       | Opportunity ID from the opportunties table                                                            | Salesforce |
| INDUSTRY                 |       | Industry from the accounts table                                                                      | Salesforce |
| INITIAL_CAMPAIGN_C       |       | Initial campaign targeted at this contact, from the contacts table                                    | Salesforce |
| INITIAL_CONTACT_METHOD_C |       | Initial contact method for this contact, from the contacts table                                      | Salesforce |
| INITIAL_CONTENT_C        |       | Initial content sent to this contact, from the contacts table                                         | Salesforce |
| INITIAL_MEDIUM_C         |       | Initial medium used to contact this individual, from the contacts table                               | Salesforce |
| INITIAL_SOURCE_DETAIL_C  |       | Details on the initial source of this contact, from the contacts table                                | Salesforce |
| JOB_TITLE_CATEGORY_C     |       | Category of the contact's position, from the contacts table                                           | Salesforce |
| LEAD_SOURCE              |       | Channel where the contact's information came from, from the contacts table                            | Salesforce |
| MAILING_CITY             |       | Contact's mailing city, from the contacts table                                                       | Salesforce |
| MAILING_COUNTRY          |       | Contact's mailing country, from the contacts table                                                    | Salesforce |
| MAILING_POSTAL_CODE      |       | Contact's mailing postal code, from the contacts table                                                | Salesforce |
| MAILING_STATE            |       | Contact's mailing state, from the contacts table                                                      | Salesforce |
| NAME                     |       | Name of the contact, from the contacts table                                                          | Salesforce |
| NUMBER_OF_EMPLOYEES      |       | Number of employees from the account table                                                            | Salesforce |
| PHONE                    |       | Contact's Phone, from the contacts table                                                              | Salesforce |
| REPORTS_TO_ID            |       | ID in contacts table of the individual this contact reports to, if available. From the contacts table | Salesforce |
| TITLE                    |       | Contact's title, from the contacts table                                                              | Salesforce |
| USE_CASE_C               |       | Use case of interest to the opportunity, from the opportunities table                                 | Salesforce |
| WEBSITE                  |       | Company website from the account table                                                                | Salesforce |


### leads_to_be_scored

|           Name           | Index |                                              Description                                              |   Source   |
| ------------------------ | ----- | ----------------------------------------------------------------------------------------------------- | ---------- |
| ACCOUNT_ID               |       | Salesforce Account ID                                                                                 | Salesforce |
| ASSISTANT_NAME           |       | Contact's assistant's name from the contacts table                                                    | Salesforce |
| ASSISTANT_PHONE          |       | Contact's assistant's phone from the contacts table                                                   | Salesforce |
| BILLING_COUNTRY          |       | Billing country from the accounts table                                                               | Salesforce |
| BILLING_POSTAL_CODE      |       | Billing postal code from the accounts table                                                           | Salesforce |
| BILLING_STATE            |       | Billing state from the accounts table                                                                 | Salesforce |
| COMPANY_NAME             |       | Company name from the account table                                                                   | Salesforce |
| CREATED_DATE             |       | Date when the contact was created from the contacts table                                             | Salesforce |
| DEPARTMENT               |       | Contact's department from the contact table                                                           | Salesforce |
| DESCRIPTION              |       | Contact's description from the contacts table                                                         | Salesforce |
| EMAIL                    |       | Contact's email from the contacts table                                                               | Salesforce |
| ID                       |       | Contact ID from the contacts table                                                                    | Salesforce |
| INDUSTRY                 |       | Industry from the accounts table                                                                      | Salesforce |
| INITIAL_CAMPAIGN_C       |       | Initial campaign targeted at this contact, from the contacts table                                    | Salesforce |
| INITIAL_CONTACT_METHOD_C |       | Initial contact method for this contact, from the contacts table                                      | Salesforce |
| INITIAL_CONTENT_C        |       | Initial content sent to this contact, from the contacts table                                         | Salesforce |
| INITIAL_MEDIUM_C         |       | Initial medium used to contact this individual, from the contacts table                               | Salesforce |
| INITIAL_SOURCE_DETAIL_C  |       | Details on the initial source of this contact, from the contacts table                                | Salesforce |
| JOB_TITLE_CATEGORY_C     |       | Category of the contact's position, from the contacts table                                           | Salesforce |
| LEAD_SOURCE              |       | Channel where the contact's information came from, from the contacts table                            | Salesforce |
| MAILING_CITY             |       | Contact's mailing city, from the contacts table                                                       | Salesforce |
| MAILING_COUNTRY          |       | Contact's mailing country, from the contacts table                                                    | Salesforce |
| MAILING_POSTAL_CODE      |       | Contact's mailing postal code, from the contacts table                                                | Salesforce |
| MAILING_STATE            |       | Contact's mailing state, from the contacts table                                                      | Salesforce |
| NAME                     |       | Name of the contact, from the contacts table                                                          | Salesforce |
| NUMBER_OF_EMPLOYEES      |       | Number of employees from the account table                                                            | Salesforce |
| PHONE                    |       | Contact's Phone, from the contacts table                                                              | Salesforce |
| REPORTS_TO_ID            |       | ID in contacts table of the individual this contact reports to, if available. From the contacts table | Salesforce |
| TITLE                    |       | Contact's title, from the contacts table                                                              | Salesforce |
| WEBSITE                  |       | Company website from the account table                                                                | Salesforce |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/lead_scoring.yml" %}