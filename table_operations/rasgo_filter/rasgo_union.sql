{# Jinja Macro to generate a query that would get all 
   the columns in a table by source_Id or fqtn
#}
{%- macro get_source_col_names(source_id=None, source_table_fqtn=None) -%}
    {%- set database, schema, table = '', '', '' -%}
    {%- if source_table_fqtn -%}
        {%- set database, schema, table = source_table_fqtn.split('.') -%}
    {%- else -%}
        {%- set database, schema, table = rasgo_source_ref(source_id).split('.') -%}
    {% endif -%}
        SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
        WHERE TABLE_CATALOG = '{{ database }}'
        AND   TABLE_SCHEMA = '{{ schema }}'
        AND   TABLE_NAME = '{{ table }}'
{%- endmacro -%}
{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}
{# Get all columns in inputted Source #}
{%- set col_names_other_source_df = run_query(get_source_col_names(source_id=source_id)) -%}
{%- set other_source_col_names = col_names_other_source_df['COLUMN_NAME'].to_list() -%}
{# Get colnames which occur across source_table and other source #}
{%- set union_cols = [] -%}
{%- for col_name in  source_col_names -%}
    {%- if col_name in  other_source_col_names -%}
        {{ union_cols.append(col_name) or '' }}
    {%- endif -%}
{%- endfor -%}
{# Generate Union Query #}
SELECT {{ union_cols | join(', ') }} from {{ rasgo_source_ref(source_id) }}
UNION
SELECT {{ union_cols | join(', ') }} from {{ source_table }}