SELECT *
{% for col, aggs in aggregations.items() -%}
  {%- for agg in aggs -%}
    {%- for offset in offsets %}
      {% set normalized_offset = -offset %}
      , {{ agg }}({{ col }}) OVER( 
        {%- if group_by %}
        PARTITION BY {{ group_by | join(", ") }} 
        {% endif -%}
        ORDER BY {{ order_by | join(", ") }} 
        {% if normalized_offset > 0 -%}
        ROWS BETWEEN CURRENT ROW AND {{ normalized_offset }} FOLLOWING
        {% else -%}
        ROWS BETWEEN {{ normalized_offset|abs }} PRECEDING AND CURRENT ROW
        {% endif -%}
      ) as {{ cleanse_name(agg + '_' + col + '_' + offset|string) }}
    {%- endfor -%}
  {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}