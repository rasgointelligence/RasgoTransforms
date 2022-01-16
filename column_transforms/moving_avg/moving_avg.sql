SELECT * 
{%- for column in input_columns -%}
    {%- for window in window_sizes -%}
        , avg({{column}}) OVER(PARTITION BY {{partition | join(", ")}} ORDER BY {{order_by | join(", ")}} ROWS BETWEEN {{window - 1}} PRECEDING AND CURRENT ROW) AS mean_{{column}}_{{window}} 
    {%- endfor %}
{%- endfor %}
FROM {{ source_table }}