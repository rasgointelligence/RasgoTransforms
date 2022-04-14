

# datarobot_score

Retrieves predictions from a DataRobot model that was deployed in Snowflake.


## Parameters

|    Argument    |    Type     |                                                                                                 Description                                                                                                  | Is Optional |
| -------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| function_name  | value       | name of the custom Snowflake function that represents the DataRobot model                                                                                                                                    |             |
| include_cols   | column_list | List of columns to select                                                                                                                                                                                    |             |
| num_explains   | value       | (Optional) the number of prediction explanations to also retrieve. Prediction explanations are computationally expensive. If you supply num_explains, you must also supply threshold_low and threshold_high. | True        |
| threshold_low  | value       | (Optional) predictions lower than this threshold will also calculate an explanation.                                                                                                                         | True        |
| threshold_high | value       | (Optional) predictions higher than this threshold will also calculate an explanation.                                                                                                                        | True        |


## Example

```python
toscore = rasgo.get.dataset(resource_key='adventureworks_sales_by_day_toscore')

# with explanations
scored = toscore.datarobot_score(function_name = 'PUBLIC.DEMO_PREDICT_NEXT_WEEK_SALES_V2',
                     include_cols = ['ORDERDATE','SALESAMOUNT'],
                     num_explains=2, 
                     threshold_low=100, 
                     threshold_high=100000)

# without explanations
scored = toscore.datarobot_score(function_name = 'PUBLIC.DEMO_PREDICT_NEXT_WEEK_SALES',
                     include_cols = ['ORDERDATE','SALESAMOUNT'])    

scored.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/datarobot_score/datarobot_score.sql" %}

