WITH CTE_SEQUENCES AS (
  SELECT
    T.*,
    ROW_NUMBER() OVER (PARTITION BY {%- for group_item in group_by %} {{ group_item }},{%- endfor -%} {{ value_col }} ORDER BY {{ order_col }}) AS RN_R97_B42_O,
    ROW_NUMBER() OVER (ORDER BY {%- for group_item in group_by %} {{ group_item }},{%- endfor -%} {{ order_col }}) AS RN_R97_B42_E
  FROM
    {{ source_table }} T
)
SELECT
  {%- for group_item in group_by %} S.{{ group_item }},{%- endfor -%}
  S.{{ value_col }} as REPEATED_VALUE,
  MIN(S.{{ order_col }}) AS FLATLINE_START_DATE,
  MAX(S.{{ order_col }}) AS FLATLINE_END_DATE,
  COUNT(*) AS OCCURRENCE_COUNT
FROM
  CTE_SEQUENCES S
GROUP BY
  {%- for group_item in group_by %} S.{{ group_item }},{%- endfor -%}
  S.{{ value_col }},
  S.RN_R97_B42_E - S.RN_R97_B42_O
HAVING COUNT(*) > {{ min_repeat_count }}