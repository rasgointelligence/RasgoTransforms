{%- if num_rows|float < 1 -%}
    {%- set sample_amount = num_rows*100 |float -%}
{% else %}
    {%- set sample_amount = num_rows~' ROWS' -%}
{% endif %}

{% if filters is defined %}
WITH filtered AS (
    SELECT * FROM {{source_table}}
    {% for filter_block in filters %}
    {%- set oloop = loop -%}
    {{ 'WHERE ' if oloop.first else ' AND ' }}
        {%- if filter_block is not mapping -%}
            {{ filter_block }}
        {%- else -%}
            {%- if filter_block['operator'] == 'CONTAINS' -%}
                {{ filter_block['operator'] }}({{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }})
            {%- else -%}
                {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
            {%- endif -%}
        {%- endif -%}
    {%- endfor -%}

)
SELECT * FROM filtered
TABLESAMPLE BERNOULLI ( {{ sample_amount }} )
{% else %}
SELECT * FROM {{source_table}}
TABLESAMPLE BERNOULLI ( {{ sample_amount }} )
{% endif %}