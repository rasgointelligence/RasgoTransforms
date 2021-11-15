SELECT *
{%- for math_op in math_ops %}
    , {{math_op}} as {{cleanse_name(math_op)}}
{%- endfor %}

FROM {{source_table}}