SELECT *
{% for col, aggs in aggregations.items() -%}
  {%- for agg in aggs %}
    , {{ agg }}({{ col }}) OVER( 
      {%- if group_by %}
      PARTITION BY {{ group_by | join(", ") }} 
      {% endif -%}
      ORDER BY {{ order_by | join(", ") }}
      {% if direction and direction.lower() == 'forward' -%}
      ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
      {% else -%}
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
      {%- endif -%}
    ) as {{ cleanse_name(agg + '_' + col) }}
  {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}