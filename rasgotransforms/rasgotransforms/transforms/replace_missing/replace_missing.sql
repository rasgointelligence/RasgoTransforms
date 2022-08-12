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
{%- if imputation | lower in  ['mean', 'median', 'mode', 'max', 'min', 'sum'] -%}
{%- set imputation = 'AVG' if imputation == 'mean' else imputation -%}
{%- set imputation_strategy = imputation | upper -%}
{%- set impute_expression = imputation_strategy + '(' + col + ') over ()' -%}
{%- else -%}
{%- set imputation = "'" + imputation + "'" if imputation is string else imputation -%}
{%- set impute_expression = imputation -%}
{%- endif -%}
coalesce({{ col }}, {{ impute_expression }}) as {{ col }}
{%- endmacro -%}

{# Macro to generate a query to flag missing values #}
{%- macro get_flag_missing_query(col) -%}
case when {{ col }} is null then 1 else 0 end as {{ col }}_missing_flag
{%- endmacro -%}


{# Get all Columns in Source Table #}
{%- set source_col_names = get_columns(source_table) -%}

select
    {%- for col in source_col_names -%}
    {%- if col in replacements %}
    {{ get_impute_query(col, replacements[col]) }}{{ ',' if flag_missing_vals or not loop.last else '' }}
    {%- if flag_missing_vals %}
    {{ get_flag_missing_query(col) }}{{ ',' if not loop.last else '' }}
    {%- endif -%}
    {%- else %} {{ col }}{{ ',' if not loop.last else '' }}
    {%- endif -%}
    {%- endfor %}
from {{ source_table }}
