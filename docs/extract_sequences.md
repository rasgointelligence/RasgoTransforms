

# extract_sequences

Extracts sequences of consecutive increase/decrease from a time-series dataset

## Parameters

|   Name   |    Type     |           Description           | Is Optional |
| -------- | ----------- | ------------------------------- | ----------- |
| group_by | column_list | Columns to group by             |             |
| order_by | column      | A single column name to sort by |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.extract_sequences(
             group_by=['FIPS'], 
             order_by='DATE',
             column='COVID_NEW_CONFIRMED'
      )
ds2.preview()

| FIPS | SEQUENCE_NUMBER | SEQUENCE_START_DATE | SEQUENCE_END_DATE | SEQUENCE_LEN | SEQUENCE_DECREASE_CNT | SEQUENCE_INCREASE_CNT |
|------|-----------------|---------------------|-------------------|--------------|-----------------------|-----------------------|
| 1033 |              10 | 2020-05-30          | 2020-06-06        |            8 |                     4 |                     3 |
| 1033 |              11 | 2020-06-09          | 2020-06-11        |            3 |                     1 |                     1 |
| 1033 |              12 | 2020-06-11          | 2020-06-15        |            5 |                     3 |                     1 |
| 1033 |              13 | 2020-06-15          | 2020-06-18        |            4 |                     1 |                     2 |
| 1033 |              14 | 2020-06-18          | 2020-06-24        |            7 |                     4 |                     2 |

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/extract_sequences/snowflake/extract_sequences.sql" %}

