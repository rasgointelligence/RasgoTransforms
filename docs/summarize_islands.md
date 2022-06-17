

# summarize_islands

Given a dataset with a date column, summarizes the data in terms of `islands`, which are periods of time where data exists. 
This is often useful in determining if your data has `gaps` where data does not exist, or exists under certain conditions.

You must set a buffer such as 7 DAYS which will determine the grain of time for which one island stops and another begins. 
 
The result is a summarized table. 


## Parameters

|       Name       |    Type     |                                                                                                              Description                                                                                                               | Is Optional |
| ---------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| group_by         | column_list | The column(s) used to partition you data into groups. Islands will be searched within each group                                                                                                                                       | True        |
| conditions       | math_list   | A list of conditions for which to apply to the data before searching for islands. For example, ["COL1 > 0","COL1 IS NOT NULL"]                                                                                                         | True        |
| date_col         | column      | The column used to create search for islands. This must be a date or datetime column.                                                                                                                                                  |             |
| buffer_date_part | date_part   | A valid SQL datepart to slice the date_col. For interval types, see [this Snowflake doc.](https://docs.snowflake.com/en/sql-reference/data-types-datetime.html#interval-constants)                                                     |             |
| buffer_size      | int         | An integer of how many `date_parts` will be considered to be a part of the same island.  Larger numbers will cause more overlaps and therefore less islands, and  smaller numbers will cause less overlaps and therefore more islands  |             |


## Example

```python
ds = rasgo.get.dataset(4721)

test = ds.apply(date_col='YEAR',
                group_cols=['BABYNAME','STATE','GENDER'],
                buffer_date_part='MONTH',
                buffer_size=24,
                conditions=['BABYCOUNT>50']
                )

test.preview()

```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/summarize_islands/summarize_islands.sql" %}

