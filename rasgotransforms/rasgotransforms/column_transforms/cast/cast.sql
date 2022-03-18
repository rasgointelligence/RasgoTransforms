{%- macro get_source_col_names(source_table_fqtn=None) -%}
    select * from {{ source_table_fqtn }} limit 0
{%- endmacro -%}

{%- if overwrite_columns == true -%}

{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df.columns.to_list() -%}

{%- set cast_columns = [] -%}
{%- for target_col, type in casts.items() -%}
    {{ cast_columns.append(target_col) or "" }}
{%- endfor -%}

{%- set untouched_cols = source_col_names | reject('in', cast_columns) -%}

SELECT
{%- for col in untouched_cols %}
    {{ ", " if not loop.first else " " }}{{ col }}
{%- endfor %}
{%- for target_col, type in casts.items() %}
    , CAST({{target_col}} AS {{type}}) AS {{target_col}}
{%- endfor %}
FROM {{ source_table }}

{%- else -%}

SELECT *
{%- for target_col, type in casts.items() %}
    , CAST({{target_col}} AS {{type}}) AS {{cleanse_name(target_col)+'_'+cleanse_name(type)}}
{%- endfor %}
FROM {{ source_table }}

{%- endif -%}