{# the strange __var__ names are meant to prevent collisions #}
{%- set source_col_names = get_columns(source_table) -%}
with
    cte_agg as (
        select *, {{ numerator }} / {{ denom }} as raw__pct from {{ source_table }}
    ),
    cte_filter as (select * from cte_agg where {{ denom }} >= {{ min_cutoff }}),
    cte_stats as (
        select avg(raw__pct) as __u__, variance_samp(raw__pct) as __v__ from cte_filter
    ),
    cte_joined as (select * from cte_agg cross join cte_stats),
    cte_coef as (
        select
            *,
            __u__ * (__u__ * (1 - __u__) / __v__ - 1) as __alpha__,
            __alpha__ * (1 - __u__) / __u__ as __beta__
        from cte_joined
    )
select
    {{ source_col_names | join(', ') }},
    raw__pct,
    ({{ numerator }} + __alpha__) / ({{ denom }} + __alpha__ + __beta__) as adj__pct
from cte_coef
