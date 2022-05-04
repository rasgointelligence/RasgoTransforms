{%- for i in range((stage|length) - 1) -%}
    SELECT
    '{{ stage[i] }}_' || CAST({{ stage[i] }} AS STRING) AS SOURCE_NODE,
    '{{ stage[i+1] }}_' || CAST({{ stage[i+1] }} AS STRING) AS DEST_NODE,
    COUNT(*) AS WIDTH
FROM {{ source_table }}
GROUP BY
    SOURCE_NODE,
    DEST_NODE
HAVING
    SOURCE_NODE IS NOT NULL AND DEST_NODE IS NOT NULL
{{ "UNION ALL" if not loop.last else "" }}
{% endfor %}
