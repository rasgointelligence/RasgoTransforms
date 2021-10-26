

# rasgo_filter

Apply one or more column filter to the source

## Parameters

|  Argument  |    Type     |                                                                      Description                                                                       |
| ---------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| dimensions | filter_dict | Dict keys are columns to filter. Values are a list of with the first element being the filter type, and second the value to apply that filter type on. |


## Example

```py
source = rasgo.get.data_source(id=363)

source.transform(
  transform_name='rasgo_filter',
  filter_dict={
    "MONTH": ["!=", 4],
    "COVID_NEW_CASES": [">=", "20"],
    "IS_2021": ["=", True]
  }
).preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/tree/main/row_operations/rasgo_filter/rasgo_filter.sql" %}

