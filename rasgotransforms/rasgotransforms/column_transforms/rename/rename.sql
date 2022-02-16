{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn=None) -%}
    select * from {{ source_table_fqtn }} limit 0
{%- endmacro -%}


{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df.columns.to_list() -%}

SELECT
{%- for target_col, new_name in renames.items() %}
    {{target_col}} AS {{new_name}}{{ ", " if not loop.last else "" }}
{%- endfor -%}
{%- for col in source_col_names %}
    {%- if col not in renames %}, {{col}}{%- endif -%}
{% endfor %}
FROM {{ source_table }}