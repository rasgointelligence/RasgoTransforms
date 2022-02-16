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

{# Get all columns in Inputted Source #}
{%- set col_names_other_source_df = run_query(get_source_col_names(source_table_fqtn=dataset2)) -%}
{%- set other_source_col_names = col_names_other_source_df.columns.to_list() -%}

{# Get Unique Columns Across Both Datasets #}
{%- set union_cols = source_col_names + other_source_col_names -%}
{%- set union_cols = union_cols | unique | list -%}

{# Generate Union Query #}
SELECT {{ union_cols | join(', ') }} FROM {{ dataset2 }}
UNION {{ 'ALL' if keep_dupes else '' }}
SELECT {{ union_cols | join(', ') }} FROM {{ source_table }}