SELECT *,
CASE WHEN ROW_NUMBER() OVER (ORDER BY {{order_by | join(", ")}} ) < (COUNT(1) OVER () * {{train_percent}}) THEN 'Train' ELSE 'Test' END AS TT_SPLIT

FROM {{ source_table }}