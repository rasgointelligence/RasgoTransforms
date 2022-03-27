{%- macro create_cte_basic(group_by, offset, date, date_part, aggregations) -%}
{% set normalized_offset = -offset %}
{% set cte_name = cleanse_name('BASIC_OFFSET_' ~ offset ~ date_part) %}
{%- do cte_list.append(cte_name) -%}

,{{ cte_name }} AS (SELECT
{% for g in group_by -%}
    A.{{ g }},
{%- endfor %}
A.{{ date }},
{% for col, aggs in aggregations.items() -%}
    {%- for agg in aggs %}
        {%- if agg == 'ENTROPY' -%}
            {%- set entropy_flag = True -%}
        {%- endif -%}
        {% if normalized_offset > 0 -%}
            {%- set alias = cleanse_name(agg ~ '_' ~ col ~ '_NEXT' + offset|string + date_part) %}
        {%- else -%}
            {%- set alias = cleanse_name(agg ~ '_' ~ col ~ '_PAST' + offset|string + date_part) %}
        {%- endif -%}
        {%- if not entropy_flag %}
            {%- if ' DISTINCT' in agg %}
                {{ agg|replace(" DISTINCT", "") }}(DISTINCT B.{{ col }}) as {{ alias }},
            {%- else %}
                {{ agg }}(B.{{ col }}) as {{ alias }},
            {%- endif -%}
            {%- do final_col_list.append(cte_name ~ '.' ~ alias) -%}
        {%- endif -%}
    {%- endfor -%}
{%- endfor -%}
COUNT(1) AS AGG_ROW_COUNT
FROM {{ source_table }} A
INNER JOIN {{ source_table }} B
ON 
    {% for g in group_by -%}
        A.{{ g }} = B.{{ g }} AND
    {% endfor %}
    1=1
WHERE 
    {% if normalized_offset > 0 -%}
        B.{{ date }} <= DATEADD({{ date_part }}, {{ normalized_offset }}, A.{{ date }})
        AND B.{{ date }} >= A.{{ date }}
    {% else -%}
        B.{{ date }} >= DATEADD({{ date_part }}, {{ normalized_offset }}, A.{{ date }})
        AND B.{{ date }} <= A.{{ date }}
    {% endif %}
GROUP BY 
{% for g in group_by %}
    A.{{ g }}, 
{% endfor -%}
  A.{{ date }})
{%- endmacro -%}
{%- macro create_cte_entropy(group_by, offset, date, date_part, entropy_aggs) -%}
{% set normalized_offset = -offset %}
{%- for col, aggs in entropy_aggs.items() -%}
{% set cte_name1 = cleanse_name('ENTROPY_OFFSET_' ~ offset ~ date_part) %}
{% set cte_name2 = cleanse_name('ENTROPY_OFFSET_' ~ offset ~ date_part ~ '_RATIO') %}
{% set cte_name3 = cleanse_name('ENTROPY_OFFSET_' ~ offset ~ date_part ~ '_ENTROPY') %}
{%- do cte_list.append(cte_name3) -%}
{% if normalized_offset > 0 -%}
    {%- set alias = cleanse_name(col ~ '_ENTROPY_NEXT' + offset|string + date_part) %}
{%- else -%}
    {%- set alias = cleanse_name(col ~ '_ENTROPY_PAST' + offset|string + date_part) %}
{%- endif -%}
{%- do final_col_list.append(cte_name3 ~ '.' ~ alias) -%}
    , {{ cte_name1 }} AS (SELECT
    {% for g in group_by -%}
        A.{{ g }},
    {%- endfor %}
    A.{{ date }},
    B.{{ col }},
    COUNT(1) AS C 
    FROM {{ source_table }} A
    INNER JOIN {{ source_table }} B
    ON 
        {% for g in group_by -%}
            A.{{ g }} = B.{{ g }} AND
        {% endfor %}
        1=1
    WHERE 
        {% if normalized_offset > 0 -%}
            B.{{ date }} >= DATEADD({{ date_part }}, {{ normalized_offset }}, A.{{ date }})
            AND B.{{ date }} > A.{{ date }}
        {% else -%}
            B.{{ date }} >= DATEADD({{ date_part }}, {{ normalized_offset }}, A.{{ date }})
            AND B.{{ date }} <= A.{{ date }}
        {% endif %}
    GROUP BY 
    {% for g in group_by %}
        A.{{ g }}, 
    {% endfor -%}
      B.{{ col }},
      A.{{ date }}
),
    {{ cte_name2 }} AS (
    SELECT
    {%- for group_item in group_by %}
        {{ group_item }},
    {%- endfor -%}
    {{ date }},
    {{ col }},
    C / SUM(C) OVER (PARTITION BY {{ group_by | join(', ') }}, {{ date }}) AS P
    FROM {{ cte_name1 }}
    ),
    {{ cte_name3 }} AS (
    SELECT 
    {%- for group_item in group_by %}
        {{ group_item }},
    {%- endfor -%} 
    {{ date }},
    -SUM(P*LOG(2,P)) AS {{ alias }}
    FROM {{ cte_name2 }}
    GROUP BY {{ group_by | join(', ') }}
    ,{{ date }})
{%- endfor -%}
{%- endmacro -%}
{%- set cte_list = [] -%}
{%- set final_col_list = [] -%}
{%- set entropy_aggs = {} -%}
{%- for col, aggs in aggregations.items() -%}
    {%- if 'ENTROPY' in aggs -%}
        {%- set _ = entropy_aggs.update({col: aggs}) -%}
    {%- endif -%}
{%- endfor -%}
WITH DUMMY1 AS (SELECT NULL FROM {{ source_table }} WHERE 1=0)
{%- for offset in offsets -%}
    {{ create_cte_basic(group_by=group_by, offset=offset, date=date, date_part=date_part, aggregations=aggregations) }}
    {{ create_cte_entropy(group_by=group_by, offset=offset, date=date, date_part=date_part, entropy_aggs=entropy_aggs) }}
{%- endfor -%}
,DUMMY2 AS (SELECT NULL FROM {{ source_table }} WHERE 1=0)
SELECT src.*, 
{{ final_col_list|join(', ') }} FROM {{ source_table }} src
{% for cte in cte_list -%}
LEFT OUTER JOIN {{ cte }} 
ON {{ cte }}.{{ date }} = src.{{ date }}
      {%- for g in group_by %}
  AND {{ cte }}.{{ g }} = src.{{ g }}
  {% endfor -%}
{%- endfor -%}