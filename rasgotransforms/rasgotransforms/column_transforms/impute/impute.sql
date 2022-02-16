{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn) -%}
    select * from {{ source_table_fqtn }} limit 0
{%- endmacro -%}

{# 
Macro to return the imputation query 
for a specified imputation col 

If strategy is not mean, median, or mode
make query to fill with supplied scalar value
else it will perform that impuattion stagety on column
#}
{%- macro get_impute_query(col, imputation) -%}
    {%- set impute_expression = '' -%}
    {%- set imputation_strategy = '' -%}
    {%- if imputation | lower in  ['mean', 'median', 'mode'] -%}
        {%- set imputation = 'AVG' if imputation == 'mean' else imputation -%}
        {%- set imputation_strategy = imputation | upper -%}
        {%- set impute_expression = imputation_strategy + '(' + col + ') over ()' -%}
    {%- else -%}
        {%- set imputation = "'" + imputation + "'" if imputation is string else imputation -%}
        {%- set impute_expression = imputation -%}
    {%- endif -%}
    COALESCE({{ col }}, {{ impute_expression }} ) as {{ col }}
{%- endmacro -%}

{# Marco to generate a query to flag missing values #}
{%- macro get_flag_missing_query(col) -%}
    CASE
        WHEN {{ col }} IS NULL then 1
        ELSE 0
    END as {{ col }}_missing_flag
{%- endmacro -%}


{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df.columns.to_list() -%}

SELECT
{%- for col in source_col_names -%}
    {%- if col in imputations %}
    {{ get_impute_query(col, imputations[col]) }}{{ ',' if flag_missing_vals or not loop.last else ''}}
    {%- if flag_missing_vals %}
    {{ get_flag_missing_query(col) }}{{ ',' if not loop.last else ''}}
    {%- endif -%}
    {%- else %}
    {{ col }}{{ ',' if not loop.last else ''}}
    {%- endif -%}
{%- endfor %}
FROM {{source_table}}