# Data Quality Check - Gaps

Analyzes and reports any gaps in a given dataset, where rows may have stopped appearing that satisfy a given condition

## Parameters

|       Name       | Type |                                                                    Description                                                                    | Is Optional |
| ---------------- | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| source_table     |      | The dataset to analyze for gaps                                                                                                                   |             |
| date_col         |      | Date column                                                                                                                                       |             |
| buffer_date_part |      | A valid SQL datepart to be used for defining how long of a gap is expected                                                                        |             |
| buffer_size      |      | An integer of how many date parts will be considered adjacent, versus a gap.                                                                      |             |
| group_cols       |      | A list of columns to "group by" when searching for gaps                                                                                           |             |
| conditions       |      | A list of conditions to qualify a "good" record (goal is to find gaps where good records dont happen). Use 1=1 if you have no special conditions. |             |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/gaps_check.yml" %}