

# label_encode

Encode target labels with value between 0 and n_classes-1. See scikit-learn's [LabelEncoder](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.LabelEncoder.html#sklearn.preprocessing.LabelEncoder) for full documentation.


## Parameters

| Argument |  Type  |         Description         | Is Optional |
| -------- | ------ | --------------------------- | ----------- |
| column   | column | Column name to label encode |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.label_encode(column='WEATHER_DESCRIPTION')
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/label_encode/snowflake/label_encode.sql" %}

