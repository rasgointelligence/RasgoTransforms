SELECT
*
FROM {{ source_table }}
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY {%- for col in natural_key %} {{col}}{{"," if not loop.last else ""}} {%- endfor %}
    ORDER BY {%- for col in order_col %} {{col}}{{"," if not loop.last else ""}} {%- endfor %} {{order_method}}
) = 1
