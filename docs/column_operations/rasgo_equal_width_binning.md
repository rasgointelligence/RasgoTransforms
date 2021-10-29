

# rasgo_equal_width_binning

Given some desired number of bins, this transformation will calculate the the boundaries for N bins and assign each value in a column a bin number between 1 and N, inclusive. These bins will be of equal width based on the min and max value within the source column.

This transformation will create a new column called {{col_to_bin}}_{{bin_count}}_EWB. This ensures that multiple equal-weight binning operations will produce column names that don't overlap.


## Parameters

|  Argument  |  Type  |              Description              |
| ---------- | ------ | ------------------------------------- |
| bin_count  | int    | the number of equal-width bins to use |
| col_to_bin | column | which column to bin                   |


## Example

```py
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
  transform_name='rasgo_equal_width_binning',
  bin_count = 6)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/column_operations/rasgo_equal_width_binning/rasgo_equal_width_binning.sql" %}

