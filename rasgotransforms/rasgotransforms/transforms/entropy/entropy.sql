{# Create global variables to track query components #}
{%- set ns = namespace() -%}
{%- set ns.base_cte='' -%}

{%- set final_col_list=[] -%}

WITH 
{% for col in columns %}
    {%- if loop.index == 1 -%}
    {%- set ns.base_cte = 'CTE_' ~ col ~ '_ENTROPY' -%}
    {%- endif -%}
CTE_{{ col }} AS (
SELECT 
    {{ group_by | join(', ') }},
    {{ col }},
    COUNT(1) AS C 
FROM {{ source_table }}
GROUP BY {{ group_by | join(', ') }},{{ col }}
),
CTE_{{ col }}_RATIO AS (
SELECT 
    {{ group_by | join(', ') }},
    {{ col }},
    C / SUM(C) OVER (PARTITION BY {{ group_by | join(', ') }}) AS P
FROM CTE_{{ col }}
),
CTE_{{ col }}_ENTROPY AS (
SELECT 
    {{ group_by | join(', ') }},
    -SUM(P*LOG(2,P)) AS {{ col }}_ENTROPY
FROM CTE_{{ col }}_RATIO
GROUP BY {{ group_by | join(', ') }}
){{ '' if loop.last else ', ' }}
{%- do final_col_list.append('CTE_' ~ col ~ '_ENTROPY.' ~ col ~ '_ENTROPY') -%}
{%- endfor %} 

SELECT 
{%- for group_item in group_by %}
    {{ ns.base_cte }}.{{ group_item}},
{%- endfor -%}
{{ final_col_list|join(', ') }}
FROM 
{% for col in columns %}
    {%- if loop.index == 1 -%}
CTE_{{ col }}_ENTROPY 
    {%- else %}
        LEFT OUTER JOIN CTE_{{ col }}_ENTROPY ON
        {%- for group_item in group_by %}
        {{ ns.base_cte }}.{{ group_item }} = CTE_{{ col }}_ENTROPY.{{ group_item }}{{ '' if loop.last else ' AND ' }}
        {%- endfor -%}
    {%- endif -%}
{%- endfor -%}