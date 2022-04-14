

# dedupe

Deduplicate a table based on a passed-in composite key. Once an order column and an order method are selected, only the top record from the resulting grouped and ordered dataset will be kept.

## Parameters

|   Argument   |    Type     |                                 Description                                  | Is Optional |
| ------------ | ----------- | ---------------------------------------------------------------------------- | ----------- |
| natural_key  | column_list | Columns forming the grain at which to remove duplicates                      |             |
| order_col    | column_list | Columns by which to order the result set, such that the first result is kept |             |
| order_method | value       | Can be "desc" or "asc". Sets the order behavior for the chosen `order_col`.  |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.dedupe(
  natural_key=["FIPS", "DS_WEATHER_ICON", "DATE"],
  order_col=["DATE", "FIPS"],
  order_method="asc"
)
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/dedupe/dedupe.sql" %}

