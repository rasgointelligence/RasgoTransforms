select *
from {{ source_table }}
order by
    {%- for col, order_method in order_by.items() %}
    {{ col }} {{ order_method }}{{ ',' if not loop.last else ' ' }}
    {%- endfor -%}
