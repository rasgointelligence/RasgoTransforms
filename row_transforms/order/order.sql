SELECT *
FROM {{source_table}}
ORDER BY 
{%- for col, order_method in order_by.items() %}
    {{ col }} {{ order_method }}{{ ',' if not loop.last else ' ' }}
{%- endfor -%}