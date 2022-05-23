{%- if num_buckets is not defined -%}
    {%- set bucket_count = 200 -%}
{%- else -%}
    {%- set bucket_count = num_buckets -%}
{%- endif -%}

WITH COUNTS AS (
SELECT
  REPLACE('{{ column }}','"') AS FEATURE
  ,COL AS VAL
  ,COUNT(1) AS REC_CT
FROM
  (SELECT CAST({{ column }} AS FLOAT) AS COL FROM {{ source_table }}
  {%- if filters is defined and filters %}
    {% for filter_block in filters %}
        {%- set oloop = loop -%}
        {{ 'WHERE ' if oloop.first else ' AND ' }}
            {%- if filter_block is not mapping -%}
                {{ filter_block }}
            {%- else -%}
                {%- if filter_block['operator'] == 'CONTAINS' -%}
                    {{ filter_block['operator'] }}({{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }})
                {%- else -%}
                    {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
                {%- endif -%}
            {%- endif -%}
    {%- endfor -%}
  {%- endif -%}
  )
WHERE
  COL IS NOT NULL
GROUP BY 2),
CALCS AS (SELECT MIN(VAL)-1 MIN_VAL, MAX(VAL)+1 MAX_VAL FROM COUNTS),
EDGES AS (SELECT MIN_VAL, MAX_VAL, (MIN_VAL-MAX_VAL) VAL_RANGE, ((MAX_VAL-MIN_VAL)/{{ bucket_count }}) BUCKET_SIZE FROM CALCS),
FREQS AS (
SELECT
  FEATURE
  ,VAL
  ,REC_CT
  ,WIDTH_BUCKET(VAL, MIN_VAL, MAX_VAL, {{ bucket_count }}) AS HIST_BUCKET
  ,MIN_VAL
  ,MAX_VAL
  ,BUCKET_SIZE
FROM
  COUNTS
CROSS JOIN EDGES)
SELECT
  MIN_VAL+((HIST_BUCKET-1)*BUCKET_SIZE) AS {{ column }}_MIN
  ,MIN_VAL+(HIST_BUCKET*BUCKET_SIZE) AS {{ column }}_MAX
  ,SUM(REC_CT) AS RECORD_COUNT
FROM
  FREQS
GROUP BY 1,2
order by 1