SELECT *
FROM {{ source_table }}
{% for filter_block in filter_statements %}
{%- set oloop = loop -%}
{{ 'WHERE ' if oloop.first else ' AND ' }}
{% if 'advancedFilterString' in filter_block -%}
{{ filter_block['advancedFilterString'] }}
{%- else -%}
    {%- if filter_block['operator'] == 'CONTAINS' -%}
{{ filter_block['operator'] }}({{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }})
    {%- else -%}
{{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
    {%- endif -%}
{%- endif -%}
{%- endfor -%}