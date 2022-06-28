WITH CTE_CONDITION AS (
SELECT {{ date_col }} AS dtm {% if group_cols -%},{% endif -%}
{% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%}
FROM {{ source_table }}
WHERE
{% if conditions -%}{% for condition in conditions -%}{{condition}}{{ " AND " if not loop.last else " " }}{%- endfor %}{% endif -%}
{% if conditions -%}AND {% endif -%}{{ date_col }} is not null
),
CTE_LAGGED AS (
SELECT
dtm{% if group_cols -%},{% endif -%} {% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%},
LAG(dtm)
OVER ({% if group_cols -%}PARTITION BY {% endif -%}{% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%} ORDER BY dtm) AS previous_datetime,
LEAD(dtm)
OVER ({% if group_cols -%}PARTITION BY {% endif -%} {% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%} ORDER BY dtm) AS next_datetime,
ROW_NUMBER() OVER ({% if group_cols -%}PARTITION BY {% endif -%} {% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%} ORDER BY CTE_CONDITION.dtm)
AS island_location
FROM CTE_CONDITION),
CTE_ISLAND_START AS (
SELECT
ROW_NUMBER() OVER ({% if group_cols -%}PARTITION BY {% endif -%} {% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%} ORDER BY dtm) AS island_number{% if group_cols -%},{% endif -%}
{% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%},
dtm AS island_start_datetime,
island_location AS island_start_location
FROM CTE_LAGGED
WHERE (DATE_DIFF( dtm, previous_datetime, {{ buffer_date_part }}) > {{ buffer_size }}
OR CTE_LAGGED.previous_datetime IS NULL)),
CTE_ISLAND_END AS (
SELECT
ROW_NUMBER()
OVER ({% if group_cols -%}PARTITION BY {% endif -%} {% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%} ORDER BY dtm) AS island_number{% if group_cols -%},{% endif -%}
{% if group_cols -%}{% for group_col in group_cols -%}{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %}{% endif -%},
dtm AS island_end_datetime,
island_location AS island_end_location
FROM CTE_LAGGED
WHERE DATE_DIFF(next_datetime, dtm, {{ buffer_date_part }}) > {{ buffer_size }} OR CTE_LAGGED.next_datetime IS NULL)
SELECT
{% if group_cols -%}{% for group_col in group_cols -%}CTE_ISLAND_START.{{group_col}}{{ ", " if not loop.last else " " }}{%- endfor %},{% endif -%}
CTE_ISLAND_START.island_start_datetime,
CTE_ISLAND_END.island_end_datetime,
DATE_DIFF(CTE_ISLAND_END.island_end_datetime, CTE_ISLAND_START.island_start_datetime, {{ buffer_date_part }}) AS ISLAND_DURATION_{{ buffer_date_part }},
(SELECT COUNT(*)
FROM CTE_LAGGED
WHERE CTE_LAGGED.dtm BETWEEN
CTE_ISLAND_START.island_start_datetime AND
CTE_ISLAND_END.island_end_datetime
{% if group_cols -%} AND {% for group_col in group_cols -%}CTE_LAGGED.{{ group_col }} = CTE_ISLAND_START.{{ group_col }} AND CTE_LAGGED.{{ group_col }} = CTE_ISLAND_START.{{ group_col }}{{ " AND " if not loop.last else " " }}{%- endfor %}{% endif -%}
)
AS island_row_count
FROM CTE_ISLAND_START
INNER JOIN CTE_ISLAND_END ON CTE_ISLAND_END.island_number = CTE_ISLAND_START.island_number
{% if group_cols -%}{% for group_col in group_cols %} AND CTE_ISLAND_START.{{ group_col }} = CTE_ISLAND_END.{{ group_col }}{%- endfor %}{% endif -%}
