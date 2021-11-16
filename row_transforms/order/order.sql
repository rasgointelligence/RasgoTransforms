SELECT *
FROM {{source_table}}
ORDER BY
{%- for col in col_list %}
    {{ col }}{{ ',' if not loop.last else ' ' }}
{%- endfor -%}
    {{ order_method }}
