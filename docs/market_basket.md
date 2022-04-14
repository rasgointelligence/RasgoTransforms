

# market_basket

Analyze historical transaction contents to understand products that are frequently purchased together.

This approach uses a transactional table to aggregate each product purchased in a transaction, and then aggregates transactions together to look for common patterns.


## Parameters

|    Argument    |  Type  |                                        Description                                         | Is Optional |
| -------------- | ------ | ------------------------------------------------------------------------------------------ | ----------- |
| transaction_id | column | Column identifying a unique event ID (i.e., transaction) for which to aggregate line items |             |
| sep            | value  | Text separator to use when aggregating the strings, i.e. ', ' or '\|'.                      |             |
| agg_column     | column | Product ID or description to use when aggregating into transactions                        |             |


## Example

```python
sales = rasgo.get.dataset(id)

ds2 = sales.market_basket(transaction_id='SALESORDERNUMBER',
                agg_column='ENGLISHPRODUCTNAME',
                sep='|')
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/market_basket/market_basket.sql" %}

