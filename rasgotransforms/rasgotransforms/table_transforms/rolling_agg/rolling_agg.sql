SELECT *
{% for col, aggs in aggregations.items() -%}
  {%- for agg in aggs -%}
    {%- for offset in offsets %}
      , {{ agg }}({{ col }}) OVER( 
        {%- if group_by %}
        PARTITION BY {{ group_by | join(", ") }} 
        {% endif -%}
        ORDER BY {{order_by}} 
        {% if offset > 0 -%}
        ROWS BETWEEN CURRENT ROW AND {{ offset|replace('-','') }} FOLLOWING
        {% else -%}
        ROWS BETWEEN {{ offset|replace('-','') }} PRECEDING AND CURRENT ROW
        {% endif -%}
      ) as {{ cleanse_name(agg + '_' + col + '_' + offset|string) }}
    {%- endfor -%}
  {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}