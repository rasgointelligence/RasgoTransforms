{% from 'filter.sql' import get_filter_statement %}

{%- set distinct_val_query -%}
select distinct {{ columns }}
from {{ source_table }}
{%- if filters is defined %}
where true AND
{{ get_filter_statement(filters) | indent }}
{%- endif %}
limit 1000
{%- endset -%}

{%- if columns is defined -%}
    {%- if 'distinct' in aggregation|lower -%}
        {{ raise_exception('Unable to count distinct with Columns. Remove Columns and try again.') }}
    {%- endif -%}
    {%- set results = run_query(distinct_val_query) -%}
    {%- if results is none -%}
        {{ raise_exception('Unable to successfully retrieve distinct values from your data warehouse.') }}
    {%- endif -%}
    {%- set distinct_vals = results[results.columns[0]].to_list() -%}
{%- endif -%}

{# Jinja Macro to get the comma separated cleansed name list #}
{%- macro get_values(distinct_values) -%}
{%- for val in distinct_vals -%}
{{ cleanse_name(val) ~ '_' ~ values }}{{ ', ' if not loop.last else '' }}
{%- endfor -%}
{%- endmacro -%}

{%- if rows is defined -%}
    {%- set group_by = rows|join(', ') ~ ', '  -%}
{%- else -%}
    {%- set group_by = '' -%}
{%- endif -%}

WITH filtered as (
    SELECT *
    FROM {{ source_table }}
    {%- if filters is defined %}
    where true AND
    {{ get_filter_statement(filters) | indent }}
    {%- endif %}
)
{% if columns is defined %}
SELECT 
    {{ group_by }}
    {{ get_values(distinct_vals) }}
FROM ( SELECT
    {{ group_by }}
    {{ values }}, 
    {{ columns }}
    FROM filtered)
PIVOT ( {{ aggregation }} ( {{ values }} ) FOR {{ columns }} IN ( '{{ distinct_vals | join("', '") }}' ) ) as p
(   {{ group_by }}
    {{ get_values(distinct_vals) }} )
{% else %}
SELECT
    {{ group_by }}
    {{ aggregation|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation|lower else ''}}{{ values }})

FROM filtered
{%- if rows is defined %}
GROUP BY {{ rows | join(', ') }}
{%- endif -%}
{%- endif -%}