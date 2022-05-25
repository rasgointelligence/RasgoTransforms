# Product-Led Growth Funnel

The product-led growth funnel tracks users through a common Software as a Service (SaaS) funnel - from awareness via marketing at top of funnel, to free product user, to qualified lead for an enterprise sales motion, to closed won. The data sources necessary to generate this accelerator are Google Analytics, Heap, and Salesforce.

## Parameters

|        Name         | Type |                  Description                  | Is Optional |
| ------------------- | ---- | --------------------------------------------- | ----------- |
| page_traffic        |      | Google Analytics daily page traffic table.    |             |
| opportunities       |      | Salesforce opportunity table                  |             |
| daily_active_users  |      | Heap daily active users table.                |             |
| daily_traffic_table |      | Google Analytics daily traffic overview table |             |


## Output Metrics

### plg_metrics

|             Name             | Index |                            Description                            | Source |
| ---------------------------- | ----- | ----------------------------------------------------------------- | ------ |
| CLOSED_WON                   |       | Weekly count of Closed Won Accounts                               |        |
| DOCS_SESSIONS                |       | Weekly count of sessions on product documentation                 |        |
| WEEKLY_USAGE                 |       | Weekly hours of usage on the product                              |        |
| ENT_WEEKLY_NEW_USERS         |       | Weekly count of new enterprise user signups                       |        |
| WEEKLY_USERS                 |       | Weekly count of number of users on the product                    |        |
| WEBSITE_SESSIONS             |       | Weekly count of sessions on the website                           |        |
| WEEKLY_USER_DAYS             |       | Weekly count of the number of user-days on the product            |        |
| ENT_WEEKLY_REPEAT_USERS      |       | Weekly count of the number of first time repeat enterprise users  |        |
| SQO                          |       | Weekly count of SQOs                                              |        |
| ENT_WEEKLY_USERS_WILL_REPEAT |       | Weekly count of new enterprise users who will use in another week |        |
| PLG_WEEKLY_USERS_WILL_REPEAT |       | Weekly count of new free users who will use in another week       |        |
| WEEK                         |       | Week this data starts on                                          |        |
| PLG_WEEKLY_NEW_USERS         |       | Weekly count of free user signups                                 |        |
| WEBSITE_USERS                |       | Weekly count of number of users on website                        |        |
| DOCS_USERS                   |       | Weekly count of number of users on product documentation          |        |
| PLG_WEEKLY_REPEAT_USERS      |       | Weekly count of the number of first time repeat free users        |        |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/plg_funnel.yml" %}