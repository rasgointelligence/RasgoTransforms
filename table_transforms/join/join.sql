{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn=None) -%}
    {%- set database, schema, table = '', '', '' -%}
    {%- if source_table_fqtn -%}
        {%- set database, schema, table = source_table_fqtn.split('.') -%}
    {%- endif -%}
        SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
        WHERE TABLE_CATALOG = '{{ database|upper }}'
        AND   TABLE_SCHEMA = '{{ schema|upper }}'
        AND   TABLE_NAME = '{{ table|upper }}'
{%- endmacro -%}

{# Jinja Macro to get the table name from source_id #}
{%- macro get_table_name(join_table) -%}
    {%- set database, schema, table = join_table.split('.') -%}
    {{ table }}
{%- endmacro -%}

{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}

{# Get all Columns and Table Name in Join Table #}
{%- set col_names_join_df = run_query(get_source_col_names(source_table_fqtn=join_table)) -%}
{%- set join_col_names = col_names_join_df['COLUMN_NAME'].to_list() -%}
{%- set join_table_name = get_table_name(join_table) -%}


SELECT
{%- for source_col in source_col_names %}
  t1.{{ source_col }}{{ ', ' if not loop.last else '' }}
{%- endfor -%}
{%- for join_col in join_col_names -%}
    {%- if join_col not in source_col_names -%}
        , t2.{{ join_col }}
    {%- elif join_col in source_col_names -%}
        , t2.{{ join_col }} as {{ cleanse_name(join_table_name)~'_'~join_col }}
    {% endif %}
{%- endfor %}
FROM {{ source_table }} as t1
{{ join_type + ' ' if join_type else '' | upper }}JOIN {{ join_table }} as t2
{%- for t1_join_col, t2_join_col in join_columns.items() %}
{{ ' AND' if not loop.first else 'ON'}} t1.{{ t1_join_col }} = t2.{{ t2_join_col }}
{%- endfor -%}