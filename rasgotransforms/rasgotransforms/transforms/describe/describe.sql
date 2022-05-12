{%- set names_types_list = get_columns(source_table) -%}


{%- for key, value in names_types_list.items() -%}
    {% if (value == 'NUMBER' or 'FLOAT' in value or 'INT' in value) %}
    SELECT
        '{{ key }}' AS FEATURE
        ,'{{ value }}' AS DTYPE
        ,COUNT(COL) as COUNT
        ,SUM(CASE WHEN COL IS NULL THEN 1 ELSE 0 END) AS NULL_COUNT
        ,COUNT(DISTINCT COL) AS UNIQUE_COUNT
        ,MODE(COL)::string as MOST_FREQUENT
        ,AVG(COL) AS MEAN
        ,STDDEV(COL) as STD_DEV
        ,MIN(COL)::string AS MIN
        ,percentile_cont(0.25) within group (order by COL) as _25_PERCENTILE
        ,percentile_cont(0.5) within group (order by COL) as _50_PERCENTILE
        ,percentile_cont(0.75) within group (order by COL) as _75_PERCENTILE
        ,MAX(COL)::string AS MAX
    FROM
        (SELECT {{key}} AS COL FROM {{ source_table }})
    {{"UNION ALL " if not loop.last else ""}}
    {% else %}
    SELECT
        '{{ key }}' AS FEATURE
        ,'{{ value }}' AS DTYPE
        ,COUNT(COL) as COUNT
        ,SUM(CASE WHEN COL IS NULL THEN 1 ELSE 0 END) AS NULL_COUNT
        ,COUNT(DISTINCT COL) AS UNIQUE_COUNT
        ,MODE(COL)::string as MOST_FREQUENT
        ,NULL AS MEAN
        ,NULL as STD_DEV
        ,MIN(COL)::string AS MIN
        ,NULL as _25_PERCENTILE
        ,NULL as _50_PERCENTILE
        ,NULL as _75_PERCENTILE
        ,MAX(COL)::string AS MAX
    FROM
        (SELECT {{key}} AS COL FROM {{ source_table }})
    {{"UNION ALL " if not loop.last else ""}}
    {% endif -%}
{%- endfor -%}