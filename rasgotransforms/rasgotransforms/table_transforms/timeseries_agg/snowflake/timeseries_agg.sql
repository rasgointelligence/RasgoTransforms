WITH
{%- for offset in offsets -%}
  {% set normalized_offset = -offset %}
OFFSET{{ cleanse_name(offset|string + date_part) }} AS (
  SELECT
  {% for g in group_by -%}
    A.{{ g }} AS OFFSET{{ cleanse_name(offset|string + date_part) }}_{{ g }},
      {%- endfor %}   
  A.{{ date }} AS OFFSET{{ cleanse_name(offset|string + date_part) }}_{{ date }},
        {% for col, aggs in aggregations.items() -%}
        {%- set inner_loop = loop -%}
            {%- for agg in aggs %}
            {%- if normalized_offset > 0 %}
                {{ agg }}(B.{{ col }}) AS {{ cleanse_name(agg + '_' + col + '_NEXT' + offset|string + date_part) }} {{ '' if loop.last and inner_loop.last else ',' }}
            {%- else %}
                {{ agg }}(B.{{ col }}) AS {{ cleanse_name(agg + '_' + col + '_PAST' + offset|string + date_part) }} {{ '' if loop.last and inner_loop.last else ',' }}
            {%- endif %}
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
SELECT * FROM {{ source_table }} src
{% for offset in offsets -%}
  {% set normalized_offset = -offset %}
LEFT OUTER JOIN OFFSET{{ cleanse_name(offset|string + date_part) }} 
ON OFFSET{{ cleanse_name(offset|string + date_part) }}.OFFSET{{ cleanse_name(offset|string + date_part) }}_{{ date }} = src.{{ date }}
      {%- for g in group_by %}
        AND src.{{ g }} = OFFSET{{ cleanse_name(offset|string + date_part) }}.OFFSET{{ cleanse_name(offset|string + date_part) }}_{{ g }}
      {% endfor -%}
      AND src.{{ date }} = OFFSET{{ cleanse_name(offset|string + date_part) }}.OFFSET{{ cleanse_name(offset|string + date_part) }}_{{ date }} 
{%- endfor -%}