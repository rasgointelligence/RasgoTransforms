WITH  CTE_RANK AS (
SELECT *, RANK() OVER(PARTITION BY {{ partition_col }} ORDER BY {{ order_col }} ASC) AS RANK_{{ order_col }}
FROM {{ source_table }}
) , 
CTE_WINDOW AS (
SELECT A.{{ partition_col }}, A.RANK_{{ order_col }}, 
ARRAY_AGG(ARRAY_CONSTRUCT(B.{{ value_col }}, B.RANK_{{ order_col }})) ARRAY_AGG_OBJ 
FROM CTE_RANK A 
JOIN CTE_RANK B 
ON A.{{ partition_col }}=B.{{ partition_col }} 
AND A.{{ order_col }} BETWEEN B.{{ order_col }} AND B.{{ order_col }}+{{ window }} 
GROUP BY A.{{ partition_col }}, A.RANK_{{ order_col }}
),
CTE_SLOPE AS
(
SELECT {{ partition_col }}, RANK_{{ order_col }}
  , regr_slope(X.VALUE[0], X.VALUE[1]) AS {{ value_col }}_SLOPE_{{ window }}
FROM CTE_WINDOW, table(flatten(ARRAY_AGG_OBJ)) X
GROUP BY {{ partition_col }}, RANK_{{ order_col }}
),
CTE_RESULT AS
(
SELECT A.{{ partition_col }}, A.{{ order_col }}, B.{{ value_col }}_SLOPE_{{ window }}
FROM CTE_RANK A
INNER JOIN CTE_SLOPE B
ON A.{{ partition_col }} = B.{{ partition_col }}
AND A.RANK_{{ order_col }} = B.RANK_{{ order_col }}
)
SELECT A.*, B.{{ value_col }}_SLOPE_{{ window }}
FROM {{ source_table }} A
LEFT OUTER JOIN CTE_RESULT B
ON A.{{ partition_col }} = B.{{ partition_col }}
AND A.{{ order_col }} = B.{{ order_col }}