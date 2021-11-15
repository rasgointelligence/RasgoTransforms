{#
Jinja Macro to generate a query that would get all 
the columns in a table by source_Id or fqtn
#}
{%- macro get_source_col_names(source_id=None, source_table_fqtn=None) -%}
    {%- set database, schema, table = '', '', '' -%}
    {%- if source_table_fqtn -%}
        {%- set database, schema, table = source_table_fqtn.split('.') -%}
    {%- else -%}
        {%- set database, schema, table = rasgo_source_ref(source_id).split('.') -%}
    {%- endif -%}
        SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
        WHERE TABLE_CATALOG = '{{ database }}'
        AND   TABLE_SCHEMA = '{{ schema }}'
        AND   TABLE_NAME = '{{ table }}'
{%- endmacro -%}

{# Jinja Macro to get the table name from source_id #}
{%- macro get_table_name(source_id) -%}
    {%- set database, schema, table = rasgo_source_ref(source_id).split('.') -%}
    {{ table }}
{%- endmacro -%}


{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}

{# Get all Columns and Table Name in Join Table #}
{%- set col_names_join_df = run_query(get_source_col_names(source_id=join_table_id)) -%}
{%- set join_col_names = col_names_join_df['COLUMN_NAME'].to_list() -%}
{%- set join_table_name = get_table_name(join_table_id) -%}



SELECT
{%- for source_col in source_col_names %}
  t1.{{ source_col }},
{%- endfor -%}


{%- for join_col in join_col_names -%}
    {# If join column name is in source table, prepend it with join table name #}
    {%- set join_col_name =  join_col -%}
    {%- if join_col in source_col_names -%}
        {%- set join_col_name =  join_table_name + '_' + join_col -%}
    {%- endif %}
  t2.{{ join_col }} as {{ join_col_name }}{{ ',' if not loop.last else '' }}
{%- endfor %}
FROM {{ source_table }} as t1
{{ join_type + ' ' if join_type else '' | upper }}JOIN {{ rasgo_source_ref(join_table_id) }} as t2
{%- for s_col in source_columns %}
{{ ' AND' if not loop.first else 'ON'}} t1.{{ s_col }} = t2.{{ joined_colums[loop.index0] }}
{%- endfor -%}