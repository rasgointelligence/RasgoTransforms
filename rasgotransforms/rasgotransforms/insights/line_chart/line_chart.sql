SELECT
{{ dimension }},

{%- for col, aggs in metrics.items() %}
        {%- set outer_loop = loop -%}
    {%- for agg in aggs %}
    {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
    {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}
GROUP BY {{ dimension }}