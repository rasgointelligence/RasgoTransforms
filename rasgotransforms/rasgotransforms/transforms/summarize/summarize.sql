{% from 'filter.sql' import get_filter_statement %}

WITH filtered as (
    SELECT *
    FROM {{ source_table }}
    {%- if filters is defined %}
    where true AND
    {{ get_filter_statement(filters) | indent }}
    {%- endif %}
)
,
summarized as (
    SELECT
    {%- if group_by is defined %}
    {{ group_by | join(', ') }},
    {%- endif %}
{%- for column, aggs in summarize.items() %}
    {%- set oloop = loop %}
    {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}}{{ ',' if not (loop.last and oloop.last) }}
    {%- endfor %}
{%- endfor %}
    FROM filtered
    {%- if group_by is defined %}
    GROUP BY {{ group_by | join(', ') }}
    {%- endif %}
) 
SELECT *
FROM summarized