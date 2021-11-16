

# order

Order a data set by a given list of columns

## Parameters

|   Argument   |    Type     |                                                       Description                                                       |
| ------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| col_list     | column_list | List of columns by which to order the data source.                                                                      |
| order_method | string      | ASC, for ascending, or DESC, for descending. This decides the order in which records will appear in the output dataset. |


## Example

```python
source = rasgo.get.data_source(id=2)

source.transform(
  transform_name='order',
  col_list=["DS_WEATHER_ICON", "DS_DAILY_HIGH_TEMP"],
  order_method="ASC"
).preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/row_transforms/order/order.sql" %}

