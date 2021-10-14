-- args: {{ aggregations }}, {{ group_items }}

-- aggregations should be a dict with column name as keys, 
-- and values the aggregation to apply to that column

SELECT
{%- for group_item in group_items %}
    {{ group_item }},
{%- endfor -%}

{%- for col, agg in aggregations.items()  %}
    {{agg}}({{col}}) as {{ col + '_' + agg }}{{'' if loop.last else ','}}
{%- endfor %}
FROM {{ source_table }}
GROUP BY {{ group_items | join(', ') }}