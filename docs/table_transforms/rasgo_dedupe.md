

# rasgo_dedupe

Deduplicate a table based on a passed-in composite key. Once an order column and an order method are selected, only the top record from the resulting grouped and ordered dataset will be kept.

## Parameters

|   Argument   |    Type     |                                 Description                                  |
| ------------ | ----------- | ---------------------------------------------------------------------------- |
| natural_key  | column_list | Columns forming the grain at which to remove duplicates                      |
| order_col    | column_list | Columns by which to order the result set, such that the first result is kept |
| order_method | value       | Can be "desc" or "asc". Sets the order behavior for the chosen `order_col`.  |


## Example

```python
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
    transform_name='rasgo_dedupe',
    natural_key=["FIPS", "DS_WEATHER_ICON", "DATE"],
    order_col=["DATE", "FIPS"],
    order_method="asc"
)

t1.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/rasgo_dedupe/rasgo_dedupe.sql" %}

