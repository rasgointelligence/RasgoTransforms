

# pivot

Transpose unique values in a single column to generate multiple columns, aggregating as needed. 
The pivot will dynamically generate a column per unique value, or you can pass a list_of_vals 
with the unique values you wish to create columns for.


## Parameters

|   Argument   |    Type     |                                                         Description                                                         | Is Optional |
| ------------ | ----------- | --------------------------------------------------------------------------------------------------------------------------- | ----------- |
| dimensions   | column_list | dimension columns after the pivot runs                                                                                      |             |
| pivot_column | column      | column to pivot and aggregate                                                                                               |             |
| value_column | column      | column with row values that will become columns                                                                             |             |
| agg_method   | agg         | method of aggregation (i.e. sum, avg, min, max, etc.)                                                                       |             |
| list_of_vals | string_list | optional argument to override the dynamic lookup of all values in the value_column and only pivot a provided list of values | True        |


## Example

Pull a source Dataset and preview it:

```python
ds = rasgo.get.dataset(id)
print(ds.preview())
```

|    | TICKER   | DATE       | SYMBOL   |   OPEN |    HIGH |     LOW |   CLOSE |           VOLUME |   ADJCLOSE |
|---:|:---------|:-----------|:---------|-------:|--------:|--------:|--------:|-----------------:|-----------:|
|  0 | SPMD     | 2021-10-13 | SPMD     |  47.15 | 47.33   | 46.7    |   47.23 | 811353           |      47.23 |
|  1 | SPMD     | 2021-10-12 | SPMD     |  46.9  | 47.275  | 46.85   |   47.04 |      1.36952e+06 |      47.04 |
|  2 | SPMD     | 2021-10-11 | SPMD     |  47.08 | 47.425  | 46.78   |   46.78 | 734657           |      46.78 |
|  3 | SPMD     | 2021-10-08 | SPMD     |  47.3  | 47.4654 | 47.02   |   47.02 | 460714           |      47.02 |
|  4 | SPMD     | 2021-10-07 | SPMD     |  46.97 | 47.6    | 46.96   |   47.29 | 656881           |      47.29 |
|  5 | SPMD     | 2021-10-06 | SPMD     |  46.29 | 46.64   | 45.8182 |   46.63 |      1.14784e+06 |      46.63 |
|  6 | SPMD     | 2021-10-05 | SPMD     |  46.79 | 47.14   | 46.5    |   46.71 | 718158           |      46.71 |
|  7 | SPMD     | 2021-10-04 | SPMD     |  46.86 | 47.14   | 46.45   |   46.65 |      1.68845e+06 |      46.65 |
|  8 | SPMD     | 2021-10-01 | SPMD     |  46.41 | 47.2    | 46      |   46.91 |      1.53162e+06 |      46.91 |
|  9 | SPMD     | 2021-09-30 | SPMD     |  47.04 | 47.12   | 46.14   |   46.16 | 895810           |      46.16 |


Transform the Dataset and preview the result:

```python
ds2 = ds.pivot(
  dimensions=['DATE'],
  pivot_column='CLOSE',
  value_column='SYMBOL',
  agg_method='AVG',
  list_of_vals=['JP','GOOG','DIS','APLE']
)
ds2.preview()
```

|    | DATE       |      JP |     GOOG |      DIS |    APLE |
|---:|:-----------|--------:|---------:|---------:|--------:|
|  0 | 2017-11-14 | 21.5273 | 1026     |  99.5327 | 16.2433 |
|  1 | 2018-09-25 |  8.26   | 1184.65  | 111.394  | 15.494  |
|  2 | 2014-06-20 |         |  554.837 |  76.2206 |         |
|  3 | 2018-07-31 | 17.5    | 1217.26  | 111.325  | 15.8779 |
|  4 | 2015-05-06 |         |  524.22  | 102.26   |         |
|  5 | 2017-08-02 |  7.2695 |  930.39  | 104.839  | 15.1934 |
|  6 | 2012-06-08 |         |  289.141 |  41.4007 |         |
|  7 | 2018-07-05 | 19.03   | 1124.27  | 102.444  | 16.0897 |
|  8 | 2009-12-24 |         |  308.085 |  28.1256 |         |
|  9 | 2008-09-03 |         |  231.338 |  27.5809 |         |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/table_transforms/pivot/pivot.sql" %}

