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

WITH GLOBAL_SPINE AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) as INTERVAL_ID,
    DATEADD('{{ interval_type }}', (INTERVAL_ID - 1), '{{ min_date }}'::timestamp_ntz) as SPINE_START,
    DATEADD('{{ interval_type }}', INTERVAL_ID, '{{ min_date }}'::timestamp_ntz) as SPINE_END
  FROM TABLE (GENERATOR(ROWCOUNT => {{ row_count }}))
), 
GROUPS AS (
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
  FROM GROUPS G
  CROSS JOIN LATERAL (
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
