{%- set source_col_names = get_columns(source_table) -%}

select
    {%- for group_item in group_by %} {{ group_item }}, {%- endfor -%}

    {%- for order_item in order_by %} {{ order_item }}, {%- endfor -%}

    {%- for source_col in source_col_names %}
    {%- if source_col not in group_by and source_col not in order_by -%}
    last_value({{ source_col }} {{ nulls }} nulls) over (
        partition by {{ group_by | join(', ') }}
        order by {{ order_by | join(', ') }}
        rows between unbounded preceding and current row
    ) as latest_{{ source_col }}{{ ', ' if not loop.last else ' ' }}
    {%- endif -%}
    {%- endfor -%}
from {{ source_table }}
