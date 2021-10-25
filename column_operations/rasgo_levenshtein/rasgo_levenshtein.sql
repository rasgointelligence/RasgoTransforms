SELECT *,
{%- for column_pair in columns | batch(2) | list %}
    {%- for cols in column_pair -%}
        EDITDISTANCE({{cols[0]}}, {{cols[1]}}) as {{cols[0]}}_{{cols[1]}}_Distance {{ ", " if not loop.last else "" }}
    {%- endfor -%}
{%- endfor -%}

FROM {{source_table}}