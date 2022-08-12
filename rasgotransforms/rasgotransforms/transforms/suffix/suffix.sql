{%- set source_col_names = get_columns(source_table) -%}
{%- set alias = cleanse_name(suffix) -%}
select
    {%- for column in source_col_names %}
    {{ column }} as {{ column~'_'~alias }}{{ ',' if not loop.last else '' }}
    {%- endfor %}
from {{ source_table }}
