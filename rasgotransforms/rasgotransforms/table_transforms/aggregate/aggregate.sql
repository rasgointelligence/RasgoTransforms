{%- set entropy_aggs = {} -%}
{%- set from_tables = [source_table] -%}
{%- for col, aggs in aggregations.items() -%}
    {%- if 'ENTROPY' in aggs -%}
        {%- set _ = entropy_aggs.update({col: aggs}) -%}
    {%- endif -%}
{%- endfor -%}

{%- for col, aggs in entropy_aggs.items() -%}
    {%- if loop.first %}
        with
    {%- endif %}
    {{ col }}_COUNTS as (
        select {{col}}, count(*) as c from {{ source_table }} group by 1
    ),
    {{ col }}_RATIOS as (
        select ratio_to_report(c) over() p_{{col}} from {{ col }}_COUNTS
    ) {{ ',' if not loop.last }}
    {%- set _ = from_tables.append(col+'_RATIOS')  -%}
{%- endfor -%}
SELECT
{% for group_item in group_by -%}
    {{ group_item }},
{%- endfor -%}

{%- for col, aggs in aggregations.items() -%}
        {%- set outer_loop = loop -%}
    {%- for agg in aggs -%}
        {%- if agg == 'ENTROPY' -%}
            -sum(p_{{ col }}*log(2,p_{{ col }})) as {{ col }}_entropy
        {%- else -%}
            {{ agg }}({{ col }}) as {{ col + '_' + agg }}
        {%- endif -%}
        {{ '' if loop.last and outer_loop.last else ',' }}
    {%- endfor -%}
{%- endfor %}
FROM {{ from_tables | join(', ') }}
{%- if group_by -%}
    GROUP BY {{ group_by | join(', ') }}
{%- endif -%}
