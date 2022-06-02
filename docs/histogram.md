

# histogram

Analyze the value distribution of a single continuous variable by binning it and calculating frequencies in each bin

## Parameters

|    Name     |    Type     |                                                      Description                                                       | Is Optional |
| ----------- | ----------- | ---------------------------------------------------------------------------------------------------------------------- | ----------- |
| column      | column      | numeric column to use to generate the histogram                                                                        |             |
| filters     | filter_list | Filter logic on one or more columns. Can choose between a simple comparison filter or advanced filter using free text. | True        |
| num_buckets | value       | max number of buckets to create; defaults to 200                                                                       | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.histogram(column='SALESAMOUNT')
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/histogram/histogram.sql" %}

