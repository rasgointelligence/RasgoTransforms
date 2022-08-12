{%- if names -%}
{%- if names|length != math_ops|length -%}

{{ raise_exception('Provide a new column alias for each math operation') }}

{%- elif names|length == math_ops|length -%}

select
    *
    {%- for math_op in math_ops %}
    , {{ math_op }} as {{ cleanse_name(names[loop.index-1]) }}
    {%- endfor %}
from {{ source_table }}

{%- endif -%}
{%- else -%}

select
    *
    {%- for math_op in math_ops %}, {{ math_op }} as {{ cleanse_name(math_op) }}
    {%- endfor %}
from {{ source_table }}

{%- endif -%}
