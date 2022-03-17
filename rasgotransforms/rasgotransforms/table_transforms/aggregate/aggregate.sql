SELECT
{%- for group_item in group_by %}
    {{ group_item }},
{%- endfor -%}

{%- for col, aggs in aggregations.items() %}
        {%- set outer_loop = loop -%}
    {%- for agg in aggs %}
    {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
    {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}
GROUP BY {{ group_by | join(', ') }}