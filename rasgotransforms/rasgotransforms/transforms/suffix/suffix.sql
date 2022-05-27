{%- set source_col_names = get_columns(source_table) -%}
{%- set alias = cleanse_name(suffix) -%}
SELECT
{%- for column in source_col_names %}
   {{column}} AS {{ column~'_'~alias }}{{',' if not loop.last else ''}}
{%- endfor %}
FROM {{ source_table }}