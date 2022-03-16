{%- set final_col_list = [] -%}
WITH
{% for offset in offsets %}
  {% set normalized_offset = -offset %}
  {% set cte_name = cleanse_name('OFFSET_' ~ offset ~ date_part) %}
{{ cte_name }} AS (
  SELECT
  {% for g in group_by -%}
    A.{{ g }} AS {{ cte_name }}_{{ g }},
      {%- endfor %}   
  A.{{ date }} AS {{ cte_name }}_{{ date }},
{% for col, aggs in aggregations.items() -%}
  {%- set inner_loop = loop -%}
  {%- for agg in aggs %}
    {% if normalized_offset > 0 -%}
      {%- set alias = cleanse_name(agg ~ '_' ~ col ~ '_NEXT' + offset|string + date_part) %}
    {%- else -%}
      {%- set alias = cleanse_name(agg ~ '_' ~ col ~ '_PAST' + offset|string + date_part) %}
    {%- endif -%}
    {{ agg }}(B.{{ col }}) AS {{ alias }}{{ '' if loop.last and inner_loop.last else ',' }}
    {%- do final_col_list.append(alias) -%}
  {%- endfor -%}
{%- endfor %}
  FROM {{ source_table }} A
  INNER JOIN {{ source_table }} B
  ON {% for g in group_by -%}
      A.{{ g }} = B.{{ g }} {{ '' if loop.last else 'AND' }}
{% endfor %}
  WHERE {% if normalized_offset > 0 -%}
  B.{{ date }} <= DATEADD({{ date_part }}, {{ normalized_offset }}, A.{{ date }})
  AND B.{{ date }} > A.{{ date }}
      {% else -%}
  B.{{ date }} >= DATEADD({{ date_part }}, {{ normalized_offset }}, A.{{ date }})
  AND B.{{ date }} < A.{{ date }}
{% endif %}
  GROUP BY {% for g in group_by %}
  A.{{ g }}, {% endfor -%}
  A.{{ date }}) {{ '' if loop.last else ',' }}
{% endfor -%}
SELECT src.*, 
{{ final_col_list|join(', ') }} FROM {{ source_table }} src
{% for offset in offsets -%}
  {% set cte_name = cleanse_name('OFFSET_' ~ offset ~ date_part) %}
  {% set normalized_offset = -offset %}
LEFT OUTER JOIN {{ cte_name }} 
ON {{ cte_name }}.{{ cte_name }}_{{ date }} = src.{{ date }}
      {%- for g in group_by %}
  AND {{ cte_name }}.{{ cte_name }}_{{ g }} = src.{{ g }}
  {% endfor -%}
{%- endfor -%}