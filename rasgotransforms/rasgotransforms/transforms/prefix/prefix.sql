{%- set source_col_names = get_columns(source_table) -%}
{%- set alias = cleanse_name(prefix) -%}
select
    {%- for column in source_col_names %}
    {{ column }} as {{ alias~'_'~column }}{{ ',' if not loop.last else '' }}
    {%- endfor %}
from {{ source_table }}
