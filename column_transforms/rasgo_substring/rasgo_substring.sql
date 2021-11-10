SELECT
*
{%- for col_expr, start_pos, end_pos in new_cols %}
    {% if end_pos is not null %}
        , SUBSTR({{ col_expr }}, {{ start_pos }}, {{ end_pos }}) AS SUBSTRING_{{ col_expr }}_{{ start_pos }}_{{ end_pos }}
    {% else %}
        , SUBSTR({{ col_expr }}, {{ start_pos }}) AS SUBSTRING_{{ col_expr }}_{{ start_pos }}
    {% endif %}
{%- endfor %}
FROM {{ source_table }}
