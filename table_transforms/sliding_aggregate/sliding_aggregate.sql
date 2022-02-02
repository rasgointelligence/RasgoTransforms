SELECT *
{%- for col, aggs in aggregations.items() %}
    {%- for window in windows -%}
        {%- for agg in aggs %}
            , {{ agg }}({{ col }}) OVER(
                PARTITION BY {{group_by | join(", ")}}
                ORDER BY {{order_by | join(", ")}}
                ROWS BETWEEN {{window}} PRECEDING AND CURRENT ROW
                ) as {{ agg + '_' + col + '_' + window|string }}
        {%- endfor -%}
    {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}