{%- if num_buckets is not defined -%}
    {%- set bucket_count = 100 -%}
{%- else -%}
    {%- set bucket_count = num_buckets -%}
{%- endif -%}
WITH AXIS_RANGE AS (
  -- Use a user-defined axis column to calculate the min & max of the axis (and buckets on the axis)
  SELECT
    MIN({{ x_axis }})-1 AS MIN_X_VAL
   ,MAX({{ x_axis }})+1 AS MAX_X_VAL
   ,MIN({{ y_axis }})-1 AS MIN_Y_VAL
   ,MAX({{ y_axis }})+1 AS MAX_Y_VAL
  FROM
    {{ source_table }}
  WHERE
    {{ x_axis }} IS NOT NULL
), EDGES AS (
SELECT MIN_X_VAL, MAX_X_VAL, (MIN_X_VAL-MAX_X_VAL) X_VAL_RANGE, ((MAX_X_VAL-MIN_X_VAL)/{{ bucket_count }}) X_BUCKET_SIZE,
  MIN_Y_VAL, MAX_Y_VAL, (MIN_Y_VAL-MAX_Y_VAL) Y_VAL_RANGE, ((MAX_Y_VAL-MIN_Y_VAL)/{{ bucket_count }}) Y_BUCKET_SIZE
  FROM AXIS_RANGE
),
BUCKETS AS (
  SELECT
    -- Assigns a bucket to each value of each column in user's column list
    -- Row count of result set should match the row count of the raw table
    MIN_X_VAL
   ,MAX_X_VAL
   ,X_BUCKET_SIZE
   ,MIN_Y_VAL
   ,MAX_Y_VAL
   ,Y_BUCKET_SIZE
   ,CAST({{ x_axis }} AS FLOAT) AS COL_X_VAL
   ,WIDTH_BUCKET(COL_X_VAL, MIN_X_VAL, MAX_X_VAL, {{ bucket_count }}) AS COL_X_BUCKET
   ,CAST({{ y_axis }} AS FLOAT) AS COL_Y_VAL
   ,WIDTH_BUCKET(COL_Y_VAL, MIN_Y_VAL, MAX_Y_VAL, {{ bucket_count }}) AS COL_Y_BUCKET
  FROM
    {{ source_table }}
    CROSS JOIN EDGES
)
-- Run final aggregates on the buckets
SELECT
   MIN_X_VAL+((COL_X_BUCKET-1)*X_BUCKET_SIZE) AS {{ x_axis }}_MIN
   ,MIN_X_VAL+(COL_X_BUCKET*X_BUCKET_SIZE) AS {{ x_axis }}_MAX
   ,MIN_Y_VAL+((COL_Y_BUCKET-1)*Y_BUCKET_SIZE) AS {{ y_axis }}_MIN
   ,MIN_Y_VAL+(COL_Y_BUCKET*Y_BUCKET_SIZE) AS {{ y_axis }}_MAX
   ,COUNT(COL_Y_VAL)+COUNT(COL_X_VAL) as DENSITY

FROM BUCKETS
WHERE {{ x_axis }}_MIN is not NULL and {{ y_axis }}_MIN is not NULL
GROUP BY 1, 2, 3, 4
ORDER BY 1, 3