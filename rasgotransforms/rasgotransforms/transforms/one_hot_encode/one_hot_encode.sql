{%- set run_query_error_message -%}
This transform depends on dynamic values to work, but no Data Warehouse connection is available. 
Instead, please use the `list_of_vals` argument to provide these values explicitly
{%- endset -%}

{%- if list_of_vals is not defined -%}
{%- set results = run_query("SELECT DISTINCT " +  column + " FROM " + source_table) -%}
{%- if results is none -%} {{ raise_exception(run_query_error_message) }} {%- endif -%}
{%- set distinct_col_vals = results[column].to_list() -%}
{%- else -%} {%- set distinct_col_vals = list_of_vals -%}
{%- endif -%}

select
    *,
    {% for val in distinct_col_vals %}
    {%- if val is not none %}
    case
        when {{ column }} = {{ "'" ~ val ~ "'" }} then 1 else 0
    end as {{ cleanse_name(column ~ '_' ~ val) }}{{ ', ' if not loop.last else '' }}
    {%- else %}
    case
        when {{ column }} is null then 1 else 0
    end as {{ column }}_is_null{{ ', ' if not loop.last else '' }}
    {%- endif -%}
    {% endfor %}
from {{ source_table }}
