{%- for col_name in stage_columns -%}
    SELECT
    '{{ col_name }}' AS LABEL
    ,SUM({{ col_name }}) AS LABEL_COUNT
FROM {{ source_table }}
{{ "UNION ALL" if not loop.last else "" }}
{% endfor %}