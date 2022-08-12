with
    cte_rank as (
        select
            *,
            row_number() over (
                partition by {{ partition_col }} order by {{ order_col }} asc
            ) as rank_{{ order_col }}
        from {{ source_table }}
    ),
    cte_window as (
        select
            a.{{ partition_col }},
            a.rank_{{ order_col }},
            array_agg(
                array_construct(b.{{ value_col }}, b.rank_{{ order_col }})
            ) array_agg_obj
        from cte_rank a
        join
            cte_rank b
            on a.{{ partition_col }}= b.{{ partition_col }}
            and a.rank_{{ order_col }}
            between b.rank_{{ order_col }} and b.rank_{{ order_col }}
            +{{ window }}
        group by a.{{ partition_col }}, a.rank_{{ order_col }}
    ),
    cte_slope as (
        select
            {{ partition_col }},
            rank_{{ order_col }},
            regr_slope(x.value[0], x.value[1]) as {{ value_col }}_slope_{{ window }}
        from cte_window, table(flatten(array_agg_obj)) x
        group by {{ partition_col }}, rank_{{ order_col }}
    ),
    cte_result as (
        select
            a.{{ partition_col }},
            a.{{ order_col }},
            b.{{ value_col }}_slope_{{ window }}
        from cte_rank a
        inner join
            cte_slope b
            on a.{{ partition_col }} = b.{{ partition_col }}
            and a.rank_{{ order_col }} = b.rank_{{ order_col }}
    )
select a.*, b.{{ value_col }}_slope_{{ window }}
from {{ source_table }} a
left outer join
    cte_result b
    on a.{{ partition_col }} = b.{{ partition_col }}
    and a.{{ order_col }} = b.{{ order_col }}
