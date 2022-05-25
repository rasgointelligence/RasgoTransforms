{%- if items is not defined -%}
    {%- if filter_statements is not defined -%}
        {{ raise_exception('items is empty: there are no filters to apply') }}
    {%- else -%}
        {%- set items = filter_statements -%}
    {%- endif -%}
{%- endif -%}

SELECT *
FROM {{ source_table }}
{% for filter_block in items %}
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