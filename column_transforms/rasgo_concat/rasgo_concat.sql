SELECT
*
{%- for col_expr, vals in new_cols %}
    CONCAT({{col_expr}}
    {%- for concatenation_val in vals %}
        , concatenation_val
    {%- endfor %}
    )
{%- endfor %}
FROM {{ source_table }}
