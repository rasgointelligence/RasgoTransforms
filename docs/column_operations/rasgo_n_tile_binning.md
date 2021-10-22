

# rasgo_n_tile_binning

Given some desired number of bins, this transformation will calculate the the boundaries for N bins and assign each value in a column a bin number between 1 and N, inclusive. The boundaries for the bins are calculated such that each bin will receive an almost equal number of elements.

## Parameters

|   Argument    |  Type  |              Description              |
| ------------- | ------ | ------------------------------------- |
| bucket_count  | int    | the number of equal-width bins to use |
| col_to_bucket | column | which column to bucket                |


## Example

```py
rasgo.read.source_data(w_source.id, limit=5)

t1 = w_source.transform(
  transform_name='rasgo_n_tile_binning',
  bucket_count = 6)

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/column_operations/rasgo_n_tile_binning/rasgo_n_tile_binning.sql" %}

