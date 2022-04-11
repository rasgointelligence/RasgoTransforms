{%- if num_buckets is not defined -%}
    {%- set bucket_count = 200 -%}
{%- else -%}
    {%- set bucket_count = num_buckets -%}
{%- endif -%}
WITH AXIS_RANGE AS (
  -- Use a user-defined axis column to calculate the min & max of the axis (and buckets on the axis)
  SELECT
    MIN({{ axis }})-1 AS MIN_VAL
   ,MAX({{ axis }})+1 AS MAX_VAL
  FROM
    {{ source_table }}
  WHERE
    {{ axis }} IS NOT NULL
), EDGES AS (
SELECT MIN_VAL, MAX_VAL, (MIN_VAL-MAX_VAL) VAL_RANGE, ((MAX_VAL-MIN_VAL)/{{ bucket_count }}) BUCKET_SIZE FROM AXIS_RANGE
),
BUCKETS AS (
  SELECT
    -- Assigns a bucket to each value of each column in user's column list
    -- Row count of result set should match the row count of the raw table
    MIN_VAL
   ,MAX_VAL
   ,BUCKET_SIZE
   ,{{ axis }}::float AS COL_A_VAL
   ,WIDTH_BUCKET(COL_A_VAL, MIN_VAL, MAX_VAL, {{ bucket_count }}) AS COL_A_BUCKET
{%- for col, aggs in metrics.items() %}
   ,{{ col }}
{%- endfor %}

  FROM
    {{ source_table }}
    CROSS JOIN EDGES
)
-- Run final aggregates on the buckets
SELECT
  MIN_VAL+((COL_A_BUCKET-1)*BUCKET_SIZE) AS {{ axis }}_MIN
  ,MIN_VAL+(COL_A_BUCKET*BUCKET_SIZE) AS {{ axis }}_MAX

{%- for col, aggs in metrics.items() %}
    {%- for agg in aggs %}
    ,{{ agg }}({{ col }})
    {%- endfor -%}
{%- endfor %}

FROM BUCKETS
WHERE {{ axis }}_MIN is not NULL
GROUP BY 1, 2
ORDER BY 1
;
