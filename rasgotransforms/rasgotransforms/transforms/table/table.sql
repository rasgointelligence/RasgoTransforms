{%- if num_rows is not defined -%}
    {%- set row_count = 10 -%}
{%- else -%}
    {%- set row_count = num_rows -%}
{%- endif -%}

SELECT *
FROM {{ source_table }}
{%- if filters is defined and filters %}
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
{%- endif %}
LIMIT {{ row_count }}