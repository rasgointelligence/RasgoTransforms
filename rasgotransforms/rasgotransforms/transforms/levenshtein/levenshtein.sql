select
    *,
    {%- for col in columns1 -%}
    {%- for col2 in columns2 %}
    editdistance(
        {{ col }}, {{ col2 }}
    ) as {{ col }}_{{ col2 }}_distance{{ ", " if not loop.last else "" }}
    {%- endfor -%} {{ ", " if not loop.last else "" }}
    {%- endfor %}
from {{ source_table }}
