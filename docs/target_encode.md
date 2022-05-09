

# target_encode

Encode a categorical column with the average value of a target column for the corresponding value of the categorical column.

See scikit-learn's [TargetEncoder](https://contrib.scikit-learn.org/category_encoders/targetencoder.html) for full documentation.


## Parameters

|  Name  |  Type  |                   Description                   | Is Optional |
| ------ | ------ | ----------------------------------------------- | ----------- |
| column | column | Column name to target encode                    |             |
| target | column | Numeric target column to use to create averages |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.target_encode(column='WEATHER_DESCRIPTION', target='DAILY_HIGH_TEMP')
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/target_encode/target_encode.sql" %}

