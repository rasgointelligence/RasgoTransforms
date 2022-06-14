

# join

Join one or more datasets together using SQL joins. Supported join types include INNER, LEFT, RIGHT.


## Parameters

|    Name    |    Type    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Is Optional |
| ---------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| join_dicts | join_dicts | List of 'join_dict' dictionaries which specify how to perform each type of join.  See example of input and output below to get a better understanding transform arguements should be defined  Each Dictionary will have the following values   1. join_type: Literal['LEFT', 'RIGHT', 'INNER']     - Type of Join to Perform   2. table_a: str dataset.FQTN (only needed if not first 'join_dict' in list)      - Specfies the table/fqtn to join in the `FROM ...` clause      - This would be the `source_table` by default if the first dictionary   3. table_b: str  ( dataset.FQTN)     - Specifies the table/fqtn to join in the `<join_type> JOIN ...` clause   4. join_prefix_b: str     - If any of the columns are the same as previous join tables, will prefix the        output column with this value   5. join_on: Dict[str, str]     - Dictionary for which columns to join on between table A and table B     - Key value pairs determine the ON part of the clause, like the string below       ON `<table_A_col_name_dict_key> = table_B_col_name_dict_value>`     - join_on dict can contain mutiple values    Example Input Output    The following transform below with produce the following SQL     ```python   internet_sales = rasgo.get.dataset(74)   customer = rasgo.get.dataset(55)   product = rasgo.get.dataset(75)    ds = product.join(join_dicts=[       {       'table_b': internet_sales.fqtn,       'join_type':'LEFT',       'join_prefix_b':'product',       'join_on':{'PRODUCTKEY':'PRODUCTKEY'}       },       {       'table_a':internet_sales.fqtn,       'table_b':customer.fqtn,       'join_on':{'CUSTOMERKEY':'CUSTOMERKEY', 'DUEDATE': 'BIRTHDATE'},       'join_type':'INNER',       'join_prefix_b':'sales'       }   ])   print(ds.sql)   ```    ```sql   SELECT ...   FROM ADVENTUREWORKS.PUBLIC.DIMPRODUCT   LEFT JOIN ADVENTUREWORKS.PUBLIC.FACTINTERNETSALES   ON DIMPRODUCT.PRODUCTKEY = FACTINTERNETSALES.PRODUCTKEY   INNER JOIN ADVENTUREWORKS.PUBLIC.DIMCUSTOMER   ON FACTINTERNETSALES.CUSTOMERKEY = DIMCUSTOMER.CUSTOMERKEY AND FACTINTERNETSALES.DUEDATE = DIMCUSTOMER.BIRTHDATE   ```  |             |


## Example

```python
internet_sales = rasgo.get.dataset(74)
customer = rasgo.get.dataset(55)
product = rasgo.get.dataset(75)

ds = product.join(join_dicts=[
      {
      'table_b': internet_sales.fqtn,
      'join_type':'LEFT',
      'join_prefix_b':'product',
      'join_on':{'PRODUCTKEY':'PRODUCTKEY'}
      },
      {
      'table_a':internet_sales.fqtn,
      'table_b':customer.fqtn,
      'join_on':{'CUSTOMERKEY':'CUSTOMERKEY', 'DUEDATE': 'BIRTHDATE'},
      'join_type':'INNER',
      'join_prefix_b':'sales'
      }
  ])
ds.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/joins/joins.sql" %}
