{% from 'filter.sql' import get_filter_statement %}

{%- set distinct_val_query -%}
select distinct {{ columns }}
from {{ source_table }}
{%- if filters is defined %}
where true AND
{{ get_filter_statement(filters) | indent }}
{%- endif %}
limit 500
{%- endset -%}

{%- if columns is defined -%}
    {%- set results = run_query(distinct_val_query) -%}
    {%- if results is none -%}
        {{ raise_exception('Unable to successfully retrieve distinct values from your data warehouse.') }}
    {%- endif -%}
    {%- set distinct_vals = results[results.columns[0]].to_list() -%}
{%- endif -%}

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
{%- for this_val in distinct_vals -%}
  {%- set oloop = loop %}
  {%- for metric in metrics %}
    {% if 'resourceKey' in metric %}
    {% do metric.__setitem__('resource_key', metric.resourceKey) %}
    {% endif %}
    {% if 'resource_key' in metric %}
        {# Lookup metric if receiving key instead of metric dict #}
        {% do metric.update(ref_metric(metric.resource_key)) %}
    {% endif %}
    {{ metric.type|upper|replace('_', '')|replace('DISTINCT', '') }}(
        {{ 'DISTINCT ' if 'DISTINCT' in metric.type|lower else ''}}
        CASE
        WHEN {{ columns }} = '{{ this_val|replace("'", "\'") }}' THEN {{ metric.target_expression }}
        ELSE NULL
        END
    ) AS {{ cleanse_name(this_val ~ '_' ~ type ~ '_' ~ metric.target_expression)}}{{ ',' if not (loop.last and oloop.last) }}
  {%- endfor %}
{%- endfor %}
FROM filtered

{%- if rows is defined %}
GROUP BY {{ rows | join(', ') }}
{%- endif %}

{%- else %}
SELECT
    {{ group_by }}
    {%- for metric in metrics %}
        {% if 'resourceKey' in metric %}
        {% do metric.__setitem__('resource_key', metric.resourceKey) %}
        {% endif %}
        {% if 'resource_key' in metric %}
            {# Lookup metric if receiving key instead of metric dict #}
            {% do metric.update(ref_metric(metric.resource_key)) %}
        {% endif %}
        {{ metric.type|upper|replace('_', '')|replace('DISTINCT', '') }}({{ 'DISTINCT ' if 'DISTINCT' in metric.type|lower else ''}}{{ metric.target_expression }}) as {{ cleanse_name(metric.type + '_' + metric.target_expression)}}{{ ',' if not (loop.last) }}
    {%- endfor %}
FROM filtered

{%- if rows is defined %}
GROUP BY {{ rows | join(', ') }}
{%- endif %}

ORDER BY
{%- for metric in metrics %}
  {{ cleanse_name(metric.type + '_' + metric.target_expression)}} DESC {{ ',' if not (loop.last) }}
{%- endfor %}
NULLS LAST
{%- endif -%}