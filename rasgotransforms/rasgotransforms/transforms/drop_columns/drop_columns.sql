{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn=None) -%}
    select * from {{ source_table_fqtn }} limit 0
{%- endmacro -%}

{% if include_cols and exclude_cols is defined %}
{{ raise_exception('You cannot pass both an include_cols list and an exclude_cols list') }}
{% else %}

{%- if include_cols is defined -%}
SELECT 
{% for col in include_cols -%}
{{col}}{{ ", " if not loop.last else " " }}
{%- endfor %}
FROM {{source_table}}
{%- endif -%}

{%- if exclude_cols is defined -%}
{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df.columns.to_list() -%}
{%- set new_columns = source_col_names | reject('in', exclude_cols) -%}


SELECT
{% for col in new_columns -%}
{{ col }}{{ ", " if not loop.last else " " }}
{%- endfor %}
FROM {{ source_table }}

{%- endif -%}
{% endif %}