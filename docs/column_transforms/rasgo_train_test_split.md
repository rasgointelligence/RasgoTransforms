

# rasgo_train_test_split

Label rows as part of the train or test set based off of percentage split you want to apply to the data

## Parameters

|   Argument    |    Type     |                                                               Description                                                               |
| ------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| order_by      | column_list | names of column(s) you want order by for the train/test split                                                                           |
| train_percent | value       | Percent of the data you want in the train set, expressed as a decimal (i.e. .8). The rest of the rows will be included in the test set. |


## Example

```python
source = rasgo.read.source_data(source.id)

t1 = source.transform(
  transform_name='rasgo_train_test_split',
  order_by = ['DATE'],
  train_percent = 0.8
)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/rasgo_train_test_split/rasgo_train_test_split.sql" %}

