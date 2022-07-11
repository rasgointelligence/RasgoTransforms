{%- for amount in window_sizes -%}
    {%- if amount < 0 -%}
        {{ raise_exception('Cannot use negative values for a moving average. Please only pass positive values in `window_sizes`.') }}
    {%- endif -%}
{%- endfor -%}
SELECT * 
{%- for column in input_columns -%}
    {%- for window in window_sizes -%}
        , avg({{column}}) OVER(PARTITION BY {{partition | join(", ")}} ORDER BY {{order_by | join(", ")}} ROWS BETWEEN {{window - 1}} PRECEDING AND CURRENT ROW) AS mean_{{column}}_{{window}} 
    {%- endfor %}
{%- endfor %}
FROM {{ source_table }}
