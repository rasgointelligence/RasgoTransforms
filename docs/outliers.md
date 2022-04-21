

# outliers

This function determines which records in the table are an outlier based on a given 
statistical method (z-score, IQR, or manual threshold) and a target column. It produces 
a new column named 'OUTLER_<target_column>' which is TRUE for records that are outliers, 
and FALSE for records that aren't.


## Parameters

|   Argument    |  Type  |                                                                                                                                                                                                                              Description                                                                                                                                                                                                                               | Is Optional |
| ------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| target_column | column | The target column containing values which will be used to calculate outliers.                                                                                                                                                                                                                                                                                                                                                                                          |             |
| method        | value  | The method used to calculate outliers. Supported methods are "iqr" which calculates the inter quartile range between the 1st and third quartile (IQR) and flags values that are more than 1.5 * IQR from the median, "z-score" which calculates the z-score and flags values with a Z-score more than the provided threshold, and "threshold" which requires and manually set minimum and maximum threshold which are used to flag outliers. Default Value = "z-score" |             |
| min_threshold | value  | The minimum threshold for values that won't be flagged as outliers. Required if method is "threshold".                                                                                                                                                                                                                                                                                                                                                                 | True        |
| max_threshold | value  | The maximum threshold for values that won't be flagged as outliers. Required if method is "threshold".                                                                                                                                                                                                                                                                                                                                                                 | True        |
| max_zscore    | value  | The maximum Z-score for values which will not be flagged as an outlier. Default Value = 2                                                                                                                                                                                                                                                                                                                                                                              | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.outliers(
      target_column="ORDERS",
      method="threshold",
      min_threshold=100,
      max_threshold=500
)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/outliers/outliers.sql" %}

