SELECT
{{ dimension }},

{%- for col, aggs in metrics.items() %}
        {%- set outer_loop = loop -%}
    {%- for agg in aggs %}
    {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
    {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}
{% if filter_statements is iterable -%}
{%- for filter_statement in filter_statements %}
{{ 'WHERE' if loop.first else 'AND' }} {{ filter_statement }}
{%- endfor -%}
{%- endif %}
GROUP BY {{ dimension }}