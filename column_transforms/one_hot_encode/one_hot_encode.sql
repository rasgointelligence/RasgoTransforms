{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn) -%}
    {%- set database, schema, table = '', '', '' -%}
    {%- set database, schema, table = source_table_fqtn.split('.') -%}
    SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
    WHERE TABLE_CATALOG = '{{ database|upper }}'
    AND   TABLE_SCHEMA = '{{ schema|upper }}'
    AND   TABLE_NAME = '{{ table|upper }}'
{%- endmacro -%}

{# Marcro to make queries for one hot encode columns #}
{%- macro gen_one_hot_encode_queries() -%}
    {%- set distinct_col_vals =  run_query("SELECT DISTINCT " +  column + " FROM " + source_table)[column].to_list() -%}
    {%- for val in  distinct_col_vals %}
    CASE WHEN {{ column }} = {{ "'" + val +  "'" if val is string else val}} THEN 1 ELSE 0 END as {{ '"' }}{{ column }}_{{ val }}{{ '"' }},
    {%- endfor %}
    CASE WHEN {{ column }} IS NULL THEN 1 ELSE 0 END as {{ column }}_IS_NULL
{%- endmacro -%}

{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}

SELECT
{%- for col in source_col_names -%}
    {%- if col != column %}
    {{ col }},
    {%- endif -%}
{%- endfor -%}
    {{ gen_one_hot_encode_queries() }}
FROM {{source_table}}