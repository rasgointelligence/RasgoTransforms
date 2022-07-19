{%- set median_aggs = dict() -%}
{%- set mode_aggs = dict() -%}
{%- for col, aggs in aggregations.items() -%}
    {%- for agg in aggs -%}
        {%- if 'MEDIAN' in agg|upper -%}
            {%- set _ = median_aggs.update({col: agg}) -%}
        {%- elif 'MODE' in agg|upper -%}
            {%- set _ = mode_aggs.update({col: agg}) -%}
        {%- endif -%}
    {%- endfor -%}
{%- endfor -%}

{%- if median_aggs -%}
    WITH MEDIAN_CTE AS(
        SELECT
            DISTINCT {{ group_by | join(', ') }}
            {%- for med_col, med_agg in median_aggs.items() %}
                ,PERCENTILE_CONT( {{ med_col }}, 0.5) OVER (PARTITION BY {{ group_by | join(', ') }}) AS {{ med_col }}_MEDIAN
            {%- endfor %}
        FROM {{ source_table }}
    ),
{%- endif -%}

{%- if mode_aggs -%}
    {%- if not median_aggs %}
    WITH
    {%- endif %}
    {%- for mode_col, mode_agg in mode_aggs.items() %}
        {{ mode_col }}_CTE AS (
            SELECT
                {{ group_by | join(',\n') }}
                ,{{ mode_col }} AS {{ mode_col }}_MODE
            FROM (
                SELECT
                    {{ group_by | join(', ') }}
                    ,{{ mode_col }}
                    ,ROW_NUMBER() OVER (PARTITION BY {{ group_by | join(', ') }} ORDER BY COUNT({{ mode_col }}) DESC) rn
                FROM {{ source_table }}
                GROUP BY {{ group_by | join(', ') }}, {{ mode_col }}
            )
            WHERE rn = 1
        ),
    {%- endfor %}
{%- endif -%}

{%- if not (median_aggs or mode_aggs) %}
WITH
{%- endif %}
AGGS AS (
    SELECT
        {{ group_by | join(',\n') }}
        {%- for col, aggs in aggregations.items() %}
            {%- set outer_loop = loop -%}
            {%- for agg in aggs %}
                {%- if ('MEDIAN' not in agg|upper and 'MODE' not in agg|upper) %}
                    {%- if ' DISTINCT' in agg|upper %}
                        ,{{ agg|replace(" DISTINCT", "") }}(DISTINCT {{ col }}) as {{ col ~ '_' ~ agg|replace(" DISTINCT", "") ~ 'DISTINCT'}}
                    {%- else %}
                        ,{{ agg }}({{ col }}) as {{ col + '_' + agg }}
                    {%- endif %}
                {%- endif %}
            {%- endfor -%}
        {%- endfor %}
    FROM {{ source_table }}
    GROUP BY {{ group_by | join(', ') }}
)
SELECT
a.*
{%- if median_aggs %}
    {%- for med_col, med_agg in median_aggs.items() %}
        ,med.{{ med_col }}_{{ med_agg }}
    {%- endfor %}
{%- endif %}
{%- if mode_aggs %}
    {%- for mode_col, mode_agg in mode_aggs.items() %}
        ,{{ mode_col }}_CTE.{{ mode_col }}_MODE
    {%- endfor %}
{%- endif %}
FROM AGGS a
{%- if median_aggs %}
    LEFT JOIN MEDIAN_CTE med
    ON
    {%- for group_col in group_by %}
        {{'a.' + group_col + ' = med.' + group_col + (' AND' if not loop.last else '')}}
    {%- endfor %}
{%- endif %}
{%- if mode_aggs %}
    {%- for mode_col, mode_agg in mode_aggs.items()  %}
        LEFT JOIN {{ mode_col }}_CTE
        ON
        {%- for group_col in group_by %}
            a.{{ group_col }} = {{ mode_col }}_CTE.{{ group_col }} {{ 'AND ' if not loop.last else '' }}
        {%- endfor %}
    {%- endfor %}
{%- endif %}
