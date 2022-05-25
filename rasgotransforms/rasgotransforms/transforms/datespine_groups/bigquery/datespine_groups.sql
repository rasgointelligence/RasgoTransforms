{% set row_count_query %}
select datediff(cast('{{ start_timestamp }}' as timestamp), cast('{{ end_timestamp }}' as timestamp), {{ interval_type }})
{% endset %}
{% set row_count_query_results = run_query(row_count_query) %}
{% set row_count = row_count_query_results[row_count_query_results.columns[0]][0] %}

WITH GLOBAL_SPINE AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) as INTERVAL_ID,
    DATEADD(cast('{{ start_timestamp }}' as timestamp), INTERVAL (INTERVAL_ID - 1) {{ interval_type }}) as SPINE_START,
    DATEADD(cast('{{ start_timestamp }}' as timestamp), INTERVAL INTERVAL_ID {{ interval_type }}) as SPINE_END
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
