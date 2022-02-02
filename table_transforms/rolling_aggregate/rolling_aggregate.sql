SELECT *
{%- for col, aggs in aggregations.items() %}
    {%- for agg in aggs %}
        , {{ agg }}({{ col }}) OVER(
          PARTITION BY {{group_by | join(", ")}}
          {{%~ if date_offset and date_part %}}
          ORDER BY DATEADD('{{date_part}}', {{date_offset}}, {{order_by}})
          RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
          {{%~ else %}}
          ORDER BY {{order_by}}
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
          {{%~ endif ~%}}
        ) as {{ agg + '_' + col }}
    {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}