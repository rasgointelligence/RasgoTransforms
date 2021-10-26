{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn) -%}
    {%- set database, schema, table = '', '', '' -%}
    {%- set database, schema, table = source_table_fqtn.split('.') -%}
    SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
    WHERE TABLE_CATALOG = '{{ database }}'
    AND   TABLE_SCHEMA = '{{ schema }}'
    AND   TABLE_NAME = '{{ table }}'
{%- endmacro -%}

{# 
Macro to return the imputation query 
for a specified imputation and col 

If startegy isn't 'mean', 'median', or 'mode'
make query to fill with supplied scalar value
else it will perform that impuattion stagety on column
#}
{%- macro get_impute_query(col, imputation) -%}
    {%- set quoted_col = '"' + col + '"' -%}
    {%- set impute_expression = '' -%}
    {%- if imputation | lower in  ['mean', 'median', 'mode'] -%}
        {%- set imputation = 'AVG' if imputation == "mean" else imputation -%}
        {%- set imputation_strategy = imputation | upper -%}
        {%- set impute_expression = imputation_strategy + "(" + quoted_col + ")" -%}
    {%- else -%}
        {%- set imputation = "'" + imputation + "'" if imputation is string else imputation -%}
        {%- set impute_expression = imputation -%}
    {%- endif -%}
    IFNULL({{ quoted_col }}, {{ impute_expression }})
{%- endmacro -%}

{{get_impute_query("col1", 1)}}

{# Get all Columns in Source Table
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}


SELECT * FROM {{source_table}}
{%- for col in source_col_names -%}
    {%- if col in imputations -%}
        {%- set quoted_col = '"' + col + '"' -%}
            IFNULL({{ quoted_col }}, impute_val)
    {%- else -%}

    {%- endif -%}
{%- endfor -%} #}
