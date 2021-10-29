

# rasgo_binning

This function will categorize or bin an input column such that for N bins, an output column is created with values `[1-N]` where each value represents some bin.

This transformation supports two binning methods (called "binning_type" in the arguments): `ntile` and `equalwidth`.

## N-tile
When using `ntile` binnint the boundaries for the bins are calculated such that each bin will receive an almost equal number of elements. It will create a new column called {{col_to_bin}}_{{bin_count}}_NTB. This ensures that multiple equal-weight binning operations will produce column names that don't overlap.

## Equal Width
The `equalwidth` method will calculate the boundraies of the such that they will be of equal width based on the min and max value within the source column. This transformation will create a new column called {{col_to_bin}}_{{bin_count}}_EWB. This ensures that multiple equal-weight binning operations will produce column names that don't overlap.


## Parameters

|   Argument    |  Type  |                        Description                        |
| ------------- | ------ | --------------------------------------------------------- |
| binning_type  | string | binning algorithm to use; must be `ntile` or `equalwidth` |
| bucket_count  | int    | the number of equal-width bins to use                     |
| col_to_bucket | column | which column to bucket                                    |


## Example

```python
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
  transform_name='rasgo_n_tile_binning',
  bucket_count = 6)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/column_transforms/rasgo-binning/rasgo-binning.sql" %}

