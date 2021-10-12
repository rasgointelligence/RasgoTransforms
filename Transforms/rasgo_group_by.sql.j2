-- args: {{aggregations}}, {{group_items}}

-- aggregations should be a list of tuples with item 1 in the tuple containg the column to apply 
--     aggregations on, with item 2 in the tuple being the aggregation to apply

SELECT
{%- for group_item in group_items %}
    {{ group_item }},
{%- endfor -%}

{%- for col, agg in aggregations  %}
    {{agg}}({{col}}) as {{ col + '_' + agg }}{{'' if loop.last else ','}}
{%- endfor %}
FROM {{ source_table }}
GROUP BY {{ group_items | join(', ') }}