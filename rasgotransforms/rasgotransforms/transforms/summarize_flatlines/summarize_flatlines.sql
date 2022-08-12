with
    cte_sequences as (
        select
            t.*,
            row_number() over (
                partition by
                    {%- for group_item in group_by %}
                    {{ group_item }},
                    {%- endfor -%} {{ value_col }}
                order by {{ order_col }}
            ) as rn_r97_b42_o,
            row_number() over (
                order by
                    {%- for group_item in group_by %}
                    {{ group_item }},
                    {%- endfor -%} {{ order_col }}
            ) as rn_r97_b42_e
        from {{ source_table }} t
    )
select
    {%- for group_item in group_by %} s.{{ group_item }},{%- endfor -%}
    s.{{ value_col }} as repeated_value,
    min(s.{{ order_col }}) as flatline_start_date,
    max(s.{{ order_col }}) as flatline_end_date,
    count(*) as occurrence_count
from cte_sequences s
group by
    {%- for group_item in group_by %} s.{{ group_item }},{%- endfor -%}
    s.{{ value_col }},
    s.rn_r97_b42_e - s.rn_r97_b42_o
having count(*) > {{ min_repeat_count }}
