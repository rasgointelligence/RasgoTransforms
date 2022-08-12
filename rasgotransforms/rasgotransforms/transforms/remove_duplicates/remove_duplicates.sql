select *
from {{ source_table }}
qualify
    row_number() over (
        partition by
            {%- for col in natural_key %}
            {{ col }}{{ "," if not loop.last else "" }}
            {%- endfor %}
        order by
            {%- for col in order_col %}
            {{ col }}{{ "," if not loop.last else "" }}
            {%- endfor %} {{ order_method }}
    )
    = 1
