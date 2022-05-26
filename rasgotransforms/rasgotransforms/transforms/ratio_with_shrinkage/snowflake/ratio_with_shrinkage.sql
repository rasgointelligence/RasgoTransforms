{# the strange __var__ names are meant to prevent collisions #}

{%- set source_col_names = get_columns(source_table) -%}
WITH CTE_AGG AS (
  SELECT 
    *, 
    {{ numerator }} / {{ denom }} as RAW__PCT 
  FROM 
    {{ source_table }}
), 
CTE_FILTER AS (
  SELECT 
    * 
  FROM 
    CTE_AGG 
  WHERE 
    {{ denom }} >= {{ min_cutoff }}
), 
CTE_STATS AS (
  SELECT 
    AVG(RAW__PCT) AS __U__, 
    VARIANCE_SAMP(RAW__PCT) AS __V__ 
  FROM 
    CTE_FILTER
), 
CTE_JOINED AS (
  SELECT 
    * 
  FROM CTE_AGG 
  CROSS JOIN CTE_STATS
), 
CTE_COEF AS (
  SELECT 
    *, 
    __U__ * (
    __U__ * (1 - __U__)/ __V__ - 1
    ) AS __ALPHA__, 
    __ALPHA__ * (1 - __U__)/ __U__ AS __BETA__ 
  FROM 
    CTE_JOINED
) 
SELECT 
  {{ source_col_names | join(', ') }},
  RAW__PCT, 
  ({{ numerator }} + __ALPHA__) / ({{ denom }} + __ALPHA__ + __BETA__) AS ADJ__PCT 
FROM 
  CTE_COEF