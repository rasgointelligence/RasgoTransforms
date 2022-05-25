{%- set source_col_names = get_columns(source_table) -%}

SELECT 
{%- for group_item in group_by %}
 {{ group_item }},
{%- endfor -%}

{%- for order_item in order_by %}
 {{ order_item }},
{%- endfor -%}

{%- for source_col in source_col_names %}
 {%- if source_col not in group_by and source_col not in order_by -%}
  LAST_VALUE({{ source_col }} {{ nulls }} NULLS) OVER (PARTITION BY {{ group_by | join(', ') }} ORDER BY {{ order_by | join(', ') }} ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS LATEST_{{ source_col }}{{ ', ' if not loop.last else ' ' }} 
 {%- endif -%}
{%- endfor -%}
FROM {{ source_table }}