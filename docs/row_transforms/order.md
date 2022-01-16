

# order

Order a dataset by a given list of columns

## Parameters

|   Argument   |    Type     |                                                       Description                                                       |
| ------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| col_list     | column_list | List of columns by which to order the data source.                                                                      |
| order_method | string      | ASC, for ascending, or DESC, for descending. This decides the order in which records will appear in the output dataset. |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.order(col_list=["DS_WEATHER_ICON", "DS_DAILY_HIGH_TEMP"], order_method="ASC")
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/row_transforms/order/order.sql" %}

