WITH base_table as (
    SELECT *
{%- for formula in new_columns %}
    , {{ formula }} as {{ cleanse_name(formula) }}
{%- endfor %}
    FROM {{ source_table }}
),
filtered_base as (
    SELECT *
    FROM {{ base_table }}
{%- for filter in filters %}
    {{ " WHERE " if loop.first else "" }}
    {%- if filter is not mapping %}
        {{ filter }}
    {%- elif filter.operator|upper == 'CONTAINS' %}
        {{ filter.operator }}({{ filter.columnName }}, {{ filter.comparisonValue }})
    {%- else %}
        {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
    {%- endif %}
    {{ " AND " if not loop.last else "" }}
{%- endfor %}
),
{%- if summarize is defined -%}
,
aggregated_base as (
    SELECT
{%- for column, aggs in summarize.items() %}
    {%- set oloop = loop %}
    {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}}{{ ',' if not (loop.last and oloop.last) }}
    {%- endfor %}
{%- endfor %}
    FROM {{ filtered_base }}
    GROUP BY {{ group_by | join(', ') }}
) 
SELECT *
FROM aggregated_base
{%- else -%}
SELECT *
FROM filtered_base
ORDER BY {{ order_by_columns | join(', ') }} {{ order_by_direction }}
{%- endif -%}