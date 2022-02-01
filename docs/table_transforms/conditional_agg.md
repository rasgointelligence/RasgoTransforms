

# conditional_agg

Pass in a list of filter rules, and aggregate rows that match.

If multiple rules are passed, they are combined and aggregated both together and separately.


## Parameters

|  Argument  |    Type    |                             Description                              | Is Optional |
| ---------- | ---------- | -------------------------------------------------------------------- | ----------- |
| rules      | value_list | List of filter rules to use                                          |             |
| agg_column | column     | Column to aggregate                                                  |             |
| agg        | agg        | Method to use when aggregating the agg_column                        |             |
| distinct   | boolean    | When aggregating the agg_column, use TRUE to qualify with a DISTINCT |             |


## Example

```python
customer = rasgo.get.dataset(55)

rules = [
  "FIRSTNAME LIKE 'J%'",
  "BIRTHDATE < '1970-01-01'",
  "ENGLISHEDUCATION = 'Bachelors'",
  "MARITALSTATUS = 'M'",
  "GENDER='F'"]

ds2 = customer.conditional_agg(rules=rules,
                              agg_column='CUSTOMERKEY',
                              agg='COUNT',
                              distinct=True)
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoUDTs/blob/main/table_transforms/conditional_agg/conditional_agg.sql" %}

