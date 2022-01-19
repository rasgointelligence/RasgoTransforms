{%- if anchor_date -%}
    {%- set THE_DATE = "DATE('" ~ anchor_date ~ "')" -%}
{%- else -%}
    {%- set THE_DATE = 'CURRENT_DATE()' -%}
{%- endif -%}

SELECT
{{ group_by | join(', ') }},
{%- for w in windows -%}
{{ agg }}(
    CASE WHEN {{ event_date }} BETWEEN {{ THE_DATE }} - {{ w }} and {{ THE_DATE }}
    THEN {{ column }}
    END) as {{ column ~ '_' ~ agg + '_' ~ w }}
    {{ '' if loop.last else ',' }}
{% endfor -%}
FROM {{ source_table }}
GROUP BY {{ group_by | join(', ') }}