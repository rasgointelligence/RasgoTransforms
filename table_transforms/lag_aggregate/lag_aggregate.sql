SELECT
    {%- for s_col in source_join_columns %}
        fct.{{ s_col }},
    {%- endfor -%}
    fct.{{ source_temporal_column }},
    {%- for lag in lag_interval_list %}
        {%- set outer_loop = loop -%}
        {%- for col, aggs in aggregations.items() %}
            {%- for agg in aggs %}
                {{ agg }}(
                    CASE
                        WHEN 
                            fct.{{ source_temporal_column}} >= (base.{{ base_temporal_column }} - INTERVAL '{{lag}} {{ lag_period_type}}')
                            AND fct.{{ source_temporal_column}} < base.{{ base_temporal_column }}
                        THEN {{ col }} 
                    END) as {{ col + '_' + agg + '_' }}{{ lag }}{{ '' if loop.last and outer_loop.last else ',' }}
            {%- endfor -%}
        {%- endfor %}
    {%- endfor %}
FROM {{ source_table }} fct
JOIN {{ rasgo_source_ref(base_source_id) }} base
{%- for s_col in source_join_columns %}
    {{ ' AND' if not loop.first else 'ON'}} fct.{{ s_col }} = base.{{ base_join_columns[loop.index0] }}    
{%- endfor -%}
   -- for some strange reason you must leave a blank line here otherwise sql gets squished when rendered

GROUP BY
fct.{{ source_temporal_column }},
{%- for s_col in source_join_columns %}
    fct.{{ s_col }}{{ '' if loop.last else ',' }}
{%- endfor -%}
