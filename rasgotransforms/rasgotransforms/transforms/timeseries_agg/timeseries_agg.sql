SELECT *
{% for offset in offsets -%}
  {% set normalized_offset = -offset %}
  {% for col, aggs in aggregations.items() -%}
    {% for agg in aggs %}
    ,(
      SELECT {{ agg }}({{ col }})
      FROM {{ source_table }} i  
      WHERE 
      {% if normalized_offset > 0 -%}
        i.{{ date }} BETWEEN o.{{ date }} AND (o.{{ date }} + INTERVAL {{ normalized_offset }} {{ date_part }})
      {% else -%}
        i.{{ date }} BETWEEN (o.{{ date }} - INTERVAL {{ normalized_offset|abs }} {{ date_part }})) AND o.{{ date }}
      {%- endif -%}
      {%- for g in group_by %}
        AND o.{{ g }} = i.{{ g }} 
      {% endfor -%}
    ) AS {{ cleanse_name(agg + '_' + col + '_' + offset|string + date_part) }}
    {%- endfor -%}
  {%- endfor %}
{% endfor %}
FROM {{ source_table }} o