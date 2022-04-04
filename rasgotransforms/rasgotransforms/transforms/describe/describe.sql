{%- macro get_col_names_types(source_table_fqtn=None) -%}
    {%- if source_table_fqtn.count('.') == 2 -%}
      {%- set database, schema, table = source_table_fqtn.split('.') -%}
        SELECT COLUMN_NAME, DATA_TYPE
        FROM {{ database }}.information_schema.columns
        WHERE TABLE_CATALOG = '{{ database|upper }}'
        AND   TABLE_SCHEMA = '{{ schema|upper }}'
        AND   TABLE_NAME = '{{ table|upper }}'
    {%- else -%}
        SELECT COLUMN_NAME, DATA_TYPE
        FROM information_schema.columns
        WHERE TABLE_NAME = '{{ source_table_fqtn|upper }}'
    {%- endif -%}
{%- endmacro -%}
{# Get all Columns in Source Table #}
{%- set names_types_df = run_query(get_col_names_types(source_table_fqtn=source_table)) -%}
{%- set names_types_list = names_types_df.set_index('COLUMN_NAME')['DATA_TYPE'].to_dict() -%}

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