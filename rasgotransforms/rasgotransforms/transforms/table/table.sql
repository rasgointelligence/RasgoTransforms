{%- if num_rows is not defined -%}
    {%- set row_count = 10 -%}
{%- else -%}
    {%- set row_count = num_rows -%}
{%- endif -%}

SELECT *
FROM {{ source_table }}
{% if filter_statements is iterable -%}
{%- for filter_statement in filter_statements %}
{{ 'WHERE' if loop.first else 'AND' }} {{ filter_statement }}
{%- endfor -%}
{%- endif %}
LIMIT {{ row_count }}