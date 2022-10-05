{%- set source_col_names = get_columns(source_table) -%}

SELECT
{%- for col in source_col_names %}
    {{ col }} as {{ cleanse_name(col) | upper }}{{ ", " if not loop.last else "" }}
{%- endfor %}
FROM {{ source_table }}