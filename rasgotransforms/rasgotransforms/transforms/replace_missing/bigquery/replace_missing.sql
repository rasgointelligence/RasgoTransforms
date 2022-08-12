{# 
Macro to return the imputation query 
for a specified imputation col 

If strategy is not mean, median, or mode
make query to fill with supplied scalar value
else it will perform that imputation stagety on column
#}
{%- macro get_impute_query(col, imputation) -%}
{%- set impute_expression = '' -%}
{%- set imputation_strategy = '' -%}
{%- if imputation | lower in  ['mean', 'max', 'min', 'sum'] -%}
{%- set imputation = 'AVG' if imputation == 'mean' else imputation -%}
{%- set imputation_strategy = imputation | upper -%}
{%- set impute_expression = imputation_strategy + '(' + col + ') over ()' -%}
{%- elif imputation|lower == "median" -%}
{%- set impute_expression = 'PERCENTILE_CONT(' + col + ', 0.5) over ()' -%}
{%- elif imputation|lower == "mode" -%}
{%- set impute_expression = col + '_MODE_VALUE' -%}
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

{%- set mode_aggs = dict() -%}
{%- for col, agg in replacements.items() -%}
{%- if 'MODE' in agg|upper -%}
{%- set _ = mode_aggs.update({col: agg}) -%}
{%- endif -%}
{%- endfor -%}

{%- if mode_aggs %}
{%- for mode_col, mode_agg in mode_aggs.items() %}
with
    {{ mode_col }}_mode_cte as (
        select
            approx_top_count({{ mode_col }}, 1)[
                offset(0)
            ].value as {{ mode_col }}_mode_value
        from {{ source_table }}
    ){{ ',' if not loop.last else '' }}
{%- endfor %}
{%- endif %}
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
from
    {{ source_table }}
    {%- if mode_aggs %}
    {%- for mode_col, mode_agg in mode_aggs.items() %}
    ,{{ mode_col }}_mode_cte
    {%- endfor %}
    {%- endif %}
