

# replace_missing

Replace missing values in column/columns with the mean, median, mode, or a value

## Parameters

|       Name        |      Type       |                                                                          Description                                                                           | Is Optional |
| ----------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| replacements      | imputation_dict | Dictionary with keys as column names to replace missing values for, and dictionary values the type of replacement strategy ('mean', 'median', 'mode', <value>) |             |
| flag_missing_vals | boolean         | Use True to create an indicator column for when a value was replaced. This column will be named like '<col_name>_missing_flag'.                                | True        |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.replace_missing(
  replacements={
      'MONTH': 'mean',            # Replace with mean 
      'FIPS': 'median',           # Replace with median
      'COVID_NEW_CASES': 'mode',  # Replace with mode
      'YEAR': '2021',             # Replace with the string '2021'
      'COVID_DEATHS': 2.45       # Replace with the number 2.45
  },
  flag_missing_vals=True)

ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/replace_missing/replace_missing.sql" %}

