{%- set run_query_error_message -%}
This transform depends on dynamic values to work, but no Datawarehouse connection is available. 
Instead, please use the `list_of_vals` argument to provide these values explicitly
{%- endset -%}

{%- if list_of_vals is not defined -%}
    {%- set distinct_col_vals =  run_query("SELECT DISTINCT " +  column + " FROM " + source_table)[column].to_list() -%}
    {%- if results is none -%}
        {{ raise_exception(run_query_error_message) }}
    {%- endif -%}
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