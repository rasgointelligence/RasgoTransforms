{%- for i in range((stage|length) - 1) -%}
    SELECT
    CAST({{ stage[i] }} AS STRING) AS SOURCE_NODE,
    CAST({{ stage[i+1] }} AS STRING) AS DEST_NODE,
    COUNT(*) AS WIDTH
FROM {{ source_table }}
GROUP BY
    SOURCE_NODE,
    DEST_NODE
HAVING
    SOURCE_NODE IS NOT NULL AND DEST_NODE IS NOT NULL
{{ "UNION" if not loop.last else "" }}
{% endfor %}
