{%- set distinct_col_vals =  run_query("SELECT DISTINCT " +  column + " FROM " + source_table)[column].to_list() -%}

SELECT *,
{% for val in distinct_col_vals %}
    {%- if val is not none %}
    CASE WHEN {{ column }} = {{ "'" ~ val ~ "'"}} THEN 1 ELSE 0 END as {{ cleanse_name(column ~ '_' ~ val) }}{{ ', ' if not loop.last else '' }}
    {%- else %}
    CASE WHEN {{ column }} IS NULL THEN 1 ELSE 0 END as {{ column }}_IS_NULL{{ ', ' if not loop.last else '' }}
    {%- endif -%}
{% endfor %}
FROM {{ source_table }}