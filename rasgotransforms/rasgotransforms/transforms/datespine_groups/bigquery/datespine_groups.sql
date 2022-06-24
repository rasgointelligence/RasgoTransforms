{% if start_timestamp is not defined or end_timestamp is not defined -%}
{%- set min_max_query -%}
select min(cast({{ date_col }} as date)) min_date, max(cast({{ date_col }} as date)) max_date from {{ source_table }}
{% endset -%}
{% set min_max_query_result = run_query(min_max_query) -%}
{% if min_max_query_result is none -%}
{{ raise_exception('start_timstamp and end_timestamp must be provided when no Data Warehouse connection is available')}}
{% endif -%}
{% endif -%}
{% if start_timestamp is defined -%}
    {% set min_date = start_timestamp -%}
{% else -%}
    {% set min_date = min_max_query_result[min_max_query_result.columns[0]][0] -%}
{% endif -%}
{% if  end_timestamp is defined -%}
    {% set max_date = end_timestamp -%}
{% else -%}
    {% set max_date = min_max_query_result[min_max_query_result.columns[1]][0] -%}
{% endif -%}
{% set row_count = (max_date|string|todatetime - min_date|string|todatetime).days + 1 -%}
with calendar as (
  select
    date_day,
    date_trunc(date_day, week) as date_week,
    date_trunc(date_day, month) as date_month,
    date_trunc(date_day, quarter) as date_quarter,
    date_trunc(date_day, year) as date_year,
    from unnest(generate_date_array('{{ min_date }}', '{{ max_date }}')) as date_day
),
GLOBAL_SPINE AS (
  select
    distinct date_{{ interval_type }} as SPINE_START,
    date_add(date_{{ interval_type }}, INTERVAL 1 {{ interval_type }}) SPINE_END,
  from calendar
), 
CATEGORIES AS (
  SELECT 
    {% for col in group_by -%}
    {{ col }},
    {%- endfor %}
    MIN({{ date_col }}) AS LOCAL_START, 
    MAX({{ date_col }}) AS LOCAL_END
  FROM {{ source_table }}
  GROUP BY 
    {% for col in group_by -%}
    {{ col }}{{ ', ' if not loop.last else ' ' }}
    {%- endfor %}
), 
GROUP_SPINE AS (
  SELECT 
    {% for col in group_by -%}
    {{ col }},
    {%- endfor %}
    SPINE_START AS GROUP_START, 
    SPINE_END AS GROUP_END
  FROM CATEGORIES G
  CROSS JOIN (
    SELECT
      SPINE_START, SPINE_END
    FROM GLOBAL_SPINE S
    {% if group_bounds == 'local' %}
    WHERE S.SPINE_START BETWEEN G.LOCAL_START AND G.LOCAL_END
    {% elif group_bounds == 'mixed' %}
    WHERE S.SPINE_START >= G.LOCAL_START
    {% endif %}
  )
)

SELECT 
  {% for col in group_by -%}
  G.{{ col }} AS GROUP_BY_{{ col }},
  {%- endfor %}
  GROUP_START, 
  GROUP_END,
  T.*
FROM GROUP_SPINE G
LEFT JOIN {{ source_table }} T
  ON {{ date_col }} >= G.GROUP_START 
  AND {{ date_col }} < G.GROUP_END 
  {% for col in group_by %} AND G.{{ col }} = T.{{ col }}
  {%- endfor %}
