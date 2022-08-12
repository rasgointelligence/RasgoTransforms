with
    cte_lag1 as (
        select
            *,
            lag({{ value_col }}, 1) over (
                partition by {{ partition_col }} order by {{ order_col }}
            ) as lag_{{ value_col }}
        from {{ source_table }}
    ),
    cte_delta as (
        select *, {{ value_col }} - lag_{{ value_col }} as delta from cte_lag1
    ),
    cte_gainloss_split as (
        select
            *,
            case when delta > 0 then delta when delta = 0 then 0 else 0 end as gain,
            case when delta < 0 then abs(delta) when delta = 0 then 0 else 0 end as loss
        from cte_delta
    ),
    cte_movingavg as (
        select
            *,
            avg(gain) over (
                partition by {{ partition_col }}
                order by {{ order_col }}
                rows between {{ window - 1 }} preceding and current row
            ) as avg_gain_{{ window }},
            avg(loss) over (
                partition by {{ partition_col }}
                order by {{ order_col }}
                rows between {{ window - 1 }} preceding and current row
            ) as avg_loss_{{ window }}
        from cte_gainloss_split
    ),
    cte_rsi as (
        select
            *,
            case
                when avg_loss_{{ window }}= 0
                then 100
                else 100 - (100 / (1 + (avg_gain_{{ window }} / avg_loss_{{ window }})))
            end as {{ value_col }}_rsi_{{ window }}
        from cte_movingavg
    ),
    cte_final as (
        select {{ order_col }}, {{ partition_col }}, {{ value_col }}_rsi_{{ window }}
        from cte_rsi
    )
select a.*, b.{{ value_col }}_rsi_{{ window }}
from {{ source_table }} a
inner join
    cte_final b
    on a.{{ partition_col }} = b.{{ partition_col }}
    and a.{{ order_col }} = b.{{ order_col }}
