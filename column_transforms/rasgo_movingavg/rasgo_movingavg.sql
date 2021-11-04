SELECT * 
{%- for column in input_columns -%}
    {%- for window in window_sizes -%}
        , avg({{column}}) OVER(PARTITION BY {{dimension}} ORDER BY {{date_dim}} ROWS BETWEEN {{window - 1}} PRECEDING AND CURRENT ROW) AS mean_{{column}}_{{window}} 
    {%- endfor -%}
{%- endfor -%}
FROM {{ source_table }}