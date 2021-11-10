SELECT
*
{%- for col_expr, new_type in new_cols %}
    -- TODO: offer an option for inplace or new column for each change?
    , TRY_CAST({{col_expr}} AS {{new_type}})
{%- endfor %}
FROM {{ source_table }}
