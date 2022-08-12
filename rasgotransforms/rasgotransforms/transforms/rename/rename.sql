
{%- set source_col_names = get_columns(source_table) -%}

select
    {%- for target_col, new_name in renames.items() %}
    {{ target_col }} as {{ new_name }}{{ ", " if not loop.last else "" }}
    {%- endfor -%}
    {%- for col in source_col_names %}
    {%- if col not in renames %}, {{ col }}{%- endif -%}
    {% endfor %}
from {{ source_table }}
