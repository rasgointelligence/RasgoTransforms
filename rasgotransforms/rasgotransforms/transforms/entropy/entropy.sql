{# Create global variables to track query components #}
{%- set ns = namespace() -%}
{%- set ns.base_cte='' -%}

{%- set final_col_list=[] -%}

with
    {% for col in columns %}
    {%- if loop.index == 1 -%}
    {%- set ns.base_cte = 'CTE_' ~ col ~ '_ENTROPY' -%}
    {%- endif -%}
    cte_{{ col }} as (
        select {{ group_by | join(', ') }}, {{ col }}, count(1) as c
        from {{ source_table }}
        group by {{ group_by | join(', ') }},{{ col }}
    ),
    cte_{{ col }}_ratio as (
        select
            {{ group_by | join(', ') }},
            {{ col }},
            c / sum(c) over (partition by {{ group_by | join(', ') }}) as p
        from cte_{{ col }}
    ),
    cte_{{ col }}_entropy as (
        select {{ group_by | join(', ') }}, - sum(p * log(2, p)) as {{ col }}_entropy
        from cte_{{ col }}_ratio
        group by {{ group_by | join(', ') }}
    ){{ '' if loop.last else ', ' }}
    {%- do final_col_list.append('CTE_' ~ col ~ '_ENTROPY.' ~ col ~ '_ENTROPY') -%}
    {%- endfor %}

select
    {%- for group_item in group_by %} {{ ns.base_cte }}.{{ group_item }}, {%- endfor -%}
    {{ final_col_list|join(', ') }}
from
{% for col in columns %}
    {%- if loop.index == 1 -%} cte_{{ col }}_entropy
{%- else %}
left outer join
    cte_{{ col }}_entropy
    on {%- for group_item in group_by %}
    {{ ns.base_cte }}.{{ group_item }}
    = cte_{{ col }}_entropy.{{ group_item }}{{ '' if loop.last else ' AND ' }}
    {%- endfor -%}
{%- endif -%}
{%- endfor -%}
