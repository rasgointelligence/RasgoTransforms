WITH CTE_LAG1 AS (
SELECT *,
        lag({{ value_col }}, 1) over (partition by {{ partition_col }} order by {{ order_col }}) as LAG_{{ value_col }}
from {{ source_table }}
) , 
CTE_DELTA AS (
SELECT *
    , {{ value_col }} - LAG_{{ value_col }}  as DELTA
FROM CTE_LAG1
) , 
CTE_GAINLOSS_SPLIT AS (
SELECT *
    , CASE WHEN DELTA > 0 THEN DELTA WHEN DELTA = 0 THEN 0 ELSE 0 END as GAIN
    , CASE WHEN DELTA < 0 THEN abs(DELTA) WHEN DELTA = 0 THEN 0 ELSE 0 END as LOSS
FROM CTE_DELTA
) , 
CTE_MOVINGAVG AS (
SELECT *
, avg(GAIN) OVER(PARTITION BY {{ partition_col }} ORDER BY {{ order_col }} ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW) AS AVG_GAIN_{{ window }}
, avg(LOSS) OVER(PARTITION BY {{ partition_col }} ORDER BY {{ order_col }} ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW) AS AVG_LOSS_{{ window }}
FROM CTE_GAINLOSS_SPLIT
) , 
CTE_RSI AS (
SELECT *
    , CASE WHEN AVG_LOSS_{{ window }}=0 THEN 100 ELSE 100 - (100 / (1+(AVG_GAIN_{{ window }} / AVG_LOSS_{{ window }}))) END as {{ value_col }}_RSI_{{ window }}
FROM CTE_MOVINGAVG
) ,
CTE_FINAL AS (
SELECT {{ order_col }}, {{ partition_col }}, {{ value_col }}_RSI_{{ window }} 
FROM CTE_RSI
)
SELECT A.*, B.{{ value_col }}_RSI_{{ window }}
FROM {{ source_table }} A
INNER JOIN CTE_FINAL B
ON A.{{ partition_col }} = B.{{ partition_col }}
AND A.{{ order_col }} = B.{{ order_col }}
