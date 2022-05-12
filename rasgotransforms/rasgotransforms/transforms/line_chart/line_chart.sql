{%- macro get_axis_data_type(source_table_fqtn=None) -%}
    {%- if source_table_fqtn.count('.') == 2 -%}
      {%- set database, schema, table = source_table_fqtn.split('.') -%}
        SELECT COLUMN_NAME, DATA_TYPE
        FROM {{ database }}.information_schema.columns
        WHERE TABLE_CATALOG = '{{ database|upper }}'
        AND   TABLE_SCHEMA = '{{ schema|upper }}'
        AND   TABLE_NAME = '{{ table|upper }}'
        AND COLUMN_NAME = '{{ axis|upper }}'
    {%- else -%}
        SELECT COLUMN_NAME, DATA_TYPE
        FROM information_schema.columns
        WHERE TABLE_NAME = '{{ source_table_fqtn|upper }}'
        AND COLUMN_NAME = '{{ axis|upper }}'
    {%- endif -%}
{%- endmacro -%}
{# Is the axis a DATE, TIMESTAMP, or something else? #}
{%- set axis_type_df = run_query(get_axis_data_type(source_table_fqtn=source_table)) -%}
{%- set axis_type_dict = axis_type_df.set_index('COLUMN_NAME')['DATA_TYPE'].to_dict() -%}
{%- if 'DATE' in axis_type_dict[axis] or 'TIMESTAMP' in axis_type_dict[axis] -%}
  {%- set axis_is_date = true -%}
{%- else -%}
  {%- set axis_is_date = false -%}
{%- endif -%}

{%- if num_buckets is not defined -%}
    {%- set bucket_count = 200 -%}
{%- else -%}
    {%- set bucket_count = num_buckets -%}
{%- endif -%}

WITH AXIS_RANGE AS (
  -- Use a user-defined axis column to calculate the min & max of the axis (and buckets on the axis)
  SELECT
    {% if axis_is_date -%}
    MIN(DATE_PART(EPOCH_SECOND, {{ axis }}))-1 AS MIN_VAL
    ,MAX(DATE_PART(EPOCH_SECOND, {{ axis }}))+1 AS MAX_VAL
    {% else -%}
    MIN({{ axis }})-1 AS MIN_VAL
   ,MAX({{ axis }})+1 AS MAX_VAL
    {%- endif %}
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
   ,{{ "DATE_PART(EPOCH_SECOND, " + axis +")" if axis_is_date else axis }}::float AS COL_A_VAL
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
  {% if axis_is_date -%}
  (MIN_VAL+((COL_A_BUCKET-1)*BUCKET_SIZE))::DATETIME AS {{ axis }}_MIN
  ,(MIN_VAL+(COL_A_BUCKET*BUCKET_SIZE))::DATETIME AS {{ axis }}_MAX
  {% else -%}
  MIN_VAL+((COL_A_BUCKET-1)*BUCKET_SIZE) AS {{ axis }}_MIN
  ,MIN_VAL+(COL_A_BUCKET*BUCKET_SIZE) AS {{ axis }}_MAX
  {%- endif %}

{%- for col, aggs in metrics.items() %}
    {%- for agg in aggs %}
    ,{{ agg }}({{ col }}) AS {{ agg }}_{{ col }}
    {%- endfor -%}
{%- endfor %}

FROM BUCKETS
WHERE {{ axis }}_MIN is not NULL
GROUP BY 1, 2
ORDER BY 1