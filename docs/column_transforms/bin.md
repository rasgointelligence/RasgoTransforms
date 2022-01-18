

# bin

This function will categorize or bin an input column such that for N bins, an output column is created with values `[1-N]` where each value represents some bin.

This transformation supports two binning methods (called "binning_type" in the arguments): `ntile` and `equalwidth`.

## N-tile
When using `ntile` binnint the boundaries for the bins are calculated such that each bin will receive an almost equal number of elements. It will create a new column called {{column}}_{{bin_count}}_NTB. This ensures that multiple equal-weight binning operations will produce column names that don't overlap.

## Equal Width
The `equalwidth` method will calculate the boundaries of the bins such that they will be of equal width based on the min and max value within the source column. This transformation will create a new column called {{column}}_{{bin_count}}_EWB. This ensures that multiple equal-weight binning operations will produce column names that don't overlap.


## Parameters

| Argument  |  Type  |                        Description                        | Is Optional |
| --------- | ------ | --------------------------------------------------------- | ----------- |
| type      | string | binning algorithm to use; must be `ntile` or `equalwidth` |             |
| bin_count | int    | the number of equal-width bins to use                     |             |
| column    | column | which column to bucket                                    |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.bin(type='equalwidth', bin_count=6, column='DAILY_HIGH_TEMP')
ds2.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/column_transforms/bin/bin.sql" %}

