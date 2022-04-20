{%- if num_rows|float < 1 -%}
    {%- set sample_amount = num_rows*100 |float -%}
{% else %}
    {%- set sample_amount = num_rows~' ROWS' -%}
{% endif %}

SELECT * FROM {{source_table}}
TABLESAMPLE BERNOULLI ( {{ sample_amount }} )
{%- for filter_statement in filter_statements %}
{{ 'WHERE' if loop.first else 'AND' }} {{ filter_statement }}
{%- endfor -%}