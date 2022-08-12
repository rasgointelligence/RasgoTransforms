with
    order_detail as (
        select
            {{ transaction_id }},
            listagg({{ agg_column }}, '{{sep}}') within group (
                order by {{ agg_column }}
            ) as {{ agg_column }}_listagg,
            count({{ agg_column }}) as num_products
        from {{ source_table }}
        group by {{ transaction_id }}
    )

select {{ agg_column }}_listagg, count({{ transaction_id }}) as numtransactions
from order_detail
where num_products > 1
group by {{ agg_column }}_listagg
order by count({{ transaction_id }}) desc
