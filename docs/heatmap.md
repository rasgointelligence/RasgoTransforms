

# heatmap

Generate an x / y heatmap, which uses the number of rows in each x/y bin as a density overlay to a 2-d histogram

## Parameters

|    Name     |    Type     |                                                      Description                                                       | Is Optional |
| ----------- | ----------- | ---------------------------------------------------------------------------------------------------------------------- | ----------- |
| x_axis      | column      | numeric column to use as the x axis                                                                                    |             |
| y_axis      | column      | numeric column to use as the y axis                                                                                    |             |
| filters     | filter_list | Filter logic on one or more columns. Can choose between a simple comparison filter or advanced filter using free text. | True        |
| num_buckets | value       | max number of buckets to create; defaults to 100                                                                       | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.heatmap(x_axis='TEMPERATURE',
  y_axis='PRECIPITATION')
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/heatmap/heatmap.sql" %}

