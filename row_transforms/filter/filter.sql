SELECT * FROM {{source_table}}
{%- for filter_statement in filter_statements %}
{{ 'WHERE' if loop.first else 'AND' }} {{ filter_statement }}
{%- endfor -%}