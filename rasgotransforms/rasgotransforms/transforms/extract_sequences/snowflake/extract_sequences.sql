with
    cte_{{ column }} as (
        select *
        from
            {{ source_table }}
            match_recognize(
                partition by {{ group_by | join(', ') }}
                order by
                    {{ order_by }}
                    measures
                    match_number() as sequence_number,
                    first({{ order_by }}) as sequence_start_date,
                    last({{ order_by }}) as sequence_end_date,
                    count(*) as sequence_len,
                    count(row_decrease.*) as sequence_decrease_cnt,
                    count(row_increase.*) as sequence_increase_cnt
                    one row per match
                    after match skip to last row_increase
                    pattern(foo row_decrease + row_increase +)
                    define
                    row_decrease as {{ column }} < lag({{ column }}),
                    row_increase as {{ column }} > lag({{ column }})
            )
    )
select *
from cte_{{ column }}
order by {{ group_by | join(', ') }}, sequence_number
