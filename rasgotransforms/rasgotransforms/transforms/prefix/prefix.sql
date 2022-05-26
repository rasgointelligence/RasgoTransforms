{%- set source_col_names = get_columns(source_table) -%}
{%- set alias = cleanse_name(prefix) -%}
SELECT
{%- for column in source_col_names %}
   {{column}} AS {{ alias~'_'~column }}{{',' if not loop.last else ''}}
{%- endfor %}
FROM {{ source_table }}