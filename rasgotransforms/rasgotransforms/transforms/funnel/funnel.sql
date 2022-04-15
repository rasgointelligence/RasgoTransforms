{%- for i in range((hierarchy|length) - 1) -%}
    SELECT
    {{ hierarchy[i] }} AS SOURCE_NODE,
    {{ hierarchy[i+1] }} AS DEST_NODE,
    COUNT(*) AS WIDTH
FROM {{ source_table }}
GROUP BY
    SOURCE_NODE,
    DEST_NODE
HAVING
    SOURCE_NODE IS NOT NULL AND DEST_NODE IS NOT NULL
{{ "UNION" if not loop.last else "" }}
{% endfor %}
