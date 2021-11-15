SELECT *,
{%- if order_by is defined %}
CASE WHEN ROW_NUMBER() OVER (ORDER BY {{order_by | join(", ")}} ) < (COUNT(1) OVER () * {{train_percent}}) THEN 'TRAIN' ELSE 'TEST' END AS TT_SPLIT
{%- else %}
CASE WHEN MOD(RANDOM(),  1/{{train_percent}}) = 0 THEN 'TEST' ELSE 'TRAIN' END AS TT_SPLIT
{%- endif %}
FROM {{ source_table }}