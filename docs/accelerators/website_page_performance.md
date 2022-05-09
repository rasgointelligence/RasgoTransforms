# Google Analytics Web Page Performance

The Web Page Performance analysis uses Google Analytics data, including bounce rate, time on page, number of visits, and total users to create a custom metric that ranks the performance of pages on your site.

## Parameters

|              Name              |  Type   |                                                     Description                                                     | Is Optional |
| ------------------------------ | ------- | ------------------------------------------------------------------------------------------------------------------- | ----------- |
| google_analytics_traffic_table | dataset | Google Analytics traffic table                                                                                      |             |
| lookback_window                | str     | This template will create metrics for a timewindow within "x" days of the current date. This is the lookback value. |             |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/website_page_performance.yml" %}