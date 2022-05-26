

# ratio_with_shrinkage

Performs empirical bayesian estimation with shrinkage towards a beta prior.
Given a dataset with a numerator and a denominator, will calculate the raw ratio as numerator / denom, 
as well as provide an adjusted ratio that shrinks the ratio towards the observed beta prior.

This is a simplified version that establishes the priors directly from the data given a min_cutoff count of observations.

NOTE: your data should already be aggregated before performing this operation.


## Parameters

|    Name    |  Type  |                                                                                                                  Description                                                                                                                  | Is Optional |
| ---------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| numerator  | column | A column that is pre-aggregated to contain the count of positive cases                                                                                                                                                                        |             |
| denom      | column | A column that is pre-aggregated to contain the count of ALL cases                                                                                                                                                                             |             |
| min_cutoff | int    | Enter a minimum value to limit the denominator when creating the prior estimates. Example: if estimating a batter's hitting percentage,  entering 500 would limit the estimation of the priors to be only for batters with over 500 at-bats.  |             |


## Example

```python
ds = rasgo.get.dataset(fqtn="BATTING_AVERAGES")

ds2 = ds.ratio_with_shrinkage(numerator = 'HITS', 
              denom = 'AT_BATS', 
              min_cutoff = 500)

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/ratio_with_shrinkage/snowflake/ratio_with_shrinkage.sql" %}

