

# rasgo_datetrunc

Truncates a date to the datepart you specif. For example, if you truncate the date '10-31-2022' to the 'month', you would get '10-1-2022'.

## Parameters

|  Argument   |    Type     |               Description                |
| ----------- | ----------- | ---------------------------------------- |
| date_column | column_list | names of column(s) you want to datetrunc |
| date_part   | date_part   | the desired grain of the date            |


## Example

```py
source = rasgo.read.source_data(source.id)

t1 = source.transform(
  transform_name='rasgo_datetrunc',
  date_part = 'month',
  date_column = 'DATE')

t1.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/column_operations/rasgo_datetrunc/rasgo_datetrunc.sql" %}

