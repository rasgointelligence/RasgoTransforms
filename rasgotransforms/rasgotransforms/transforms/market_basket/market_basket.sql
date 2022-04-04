WITH order_detail as
(SELECT {{transaction_id}},
listagg({{agg_column}}, '{{sep}}')
WITHIN group (order by {{agg_column}}) as {{agg_column}}_listagg,
COUNT({{agg_column}}) as num_products
FROM {{ source_table }}
GROUP BY {{transaction_id}} )

SELECT {{agg_column}}_listagg, count({{transaction_id}}) as NumTransactions
FROM order_detail
where num_products > 1
GROUP BY {{agg_column}}_listagg
order by count({{transaction_id}}) desc