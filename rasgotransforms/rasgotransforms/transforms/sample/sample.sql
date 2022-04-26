{%- if num_rows|float < 1 -%}
    {%- set sample_amount = num_rows*100 |float -%}
{% else %}
    {%- set sample_amount = num_rows~' ROWS' -%}
{% endif %}

{% if filter_statements is defined %}
WITH filtered AS (
    SELECT * FROM {{source_table}}
    {%- for filter_statement in filter_statements %}
    {{ 'WHERE' if loop.first else 'AND' }} {{ filter_statement }}
    {%- endfor -%}

)
SELECT * FROM filtered
TABLESAMPLE BERNOULLI ( {{ sample_amount }} )
{% else %}
SELECT * FROM {{source_table}}
TABLESAMPLE BERNOULLI ( {{ sample_amount }} )
{% endif %}