-- For a single column ("LABEL") stage return:
{%- for col_name in stage_columns -%}
    SELECT
    '{{ col_name }}' AS LABEL
    ,SUM({{ col_name }}) AS "Count"
FROM {{ source_table }}
{{ "UNION ALL" if not loop.last else "" }}
{% endfor %}

-- OR, for a multi-column stage return:
-- SELECT
-- {%- for col_name in stage_columns -%}
-- {{ "," if not loop.first else "" }}SUM({{ col_name }})
-- {% endfor %}
-- FROM {{ source_table }}