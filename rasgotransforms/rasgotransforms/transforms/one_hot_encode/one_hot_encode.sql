{%- set run_query_error_message -%}
This transform depends on dynamic values to work, but no Data Warehouse connection is available. 
Instead, please use the `list_of_vals` argument to provide these values explicitly
{%- endset -%}

{%- if list_of_vals is not defined -%}
    {%- set results = run_query("SELECT DISTINCT " +  column + " FROM " + source_table) -%}
    {%- if results is none -%}
        {{ raise_exception(run_query_error_message) }}
    {%- endif -%}
    {%- set distinct_col_vals = results[column].to_list() -%}
{%- else -%}
    {%- set distinct_col_vals = list_of_vals -%}
{%- endif -%}

SELECT *,
{% for val in distinct_col_vals %}
    {%- if val is not none %}
    CASE WHEN {{ column }} = {{ "'" ~ val ~ "'"}} THEN 1 ELSE 0 END as {{ cleanse_name(column ~ '_' ~ val) }}{{ ', ' if not loop.last else '' }}
    {%- else %}
    CASE WHEN {{ column }} IS NULL THEN 1 ELSE 0 END as {{ column }}_IS_NULL{{ ', ' if not loop.last else '' }}
    {%- endif -%}
{% endfor %}
FROM {{ source_table }}