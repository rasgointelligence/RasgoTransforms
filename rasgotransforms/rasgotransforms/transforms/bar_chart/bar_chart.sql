SELECT
{{ dimension }},

{%- for col, aggs in metrics.items() %}
        {%- set outer_loop = loop -%}
    {%- for agg in aggs %}
        {%- if ' DISTINCT' in agg %}
            {{ agg|replace(" DISTINCT", "") }}(DISTINCT {{ col }}) as {{ cleanse_name(col ~ '_' ~ agg) }}{{ '' if loop.last and outer_loop.last else ',' }}
        {%- else -%}
            {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
        {%- endif -%}
    {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}
GROUP BY {{ dimension }}