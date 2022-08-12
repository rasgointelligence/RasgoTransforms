{%- macro create_cte_basic(group_by, offset, date, date_part, aggregations) -%}
{% set normalized_offset = -offset %}
{% set cte_name = cleanse_name('BASIC_OFFSET_' ~ offset ~ date_part) %}
{%- do cte_list.append(cte_name) -%},
{{ cte_name }} as (
    select
        {% for g in group_by -%} a.{{ g }}, {%- endfor %}
        a.{{ date }},
        {% for col, aggs in aggregations.items() -%}
        {%- for agg in aggs %}
        {%- if agg == 'ENTROPY' -%} {%- set entropy_flag = True -%} {%- endif -%}
        {% if normalized_offset > 0 -%}
        {%- set alias = cleanse_name(agg ~ '_' ~ col ~ '_NEXT' + offset|string + date_part) %}
        {%- else -%}
        {%- set alias = cleanse_name(agg ~ '_' ~ col ~ '_PAST' + offset|string + date_part) %}
        {%- endif -%}
        {%- if not entropy_flag %}
        {%- if ' DISTINCT' in agg %}
        {{ agg|replace(" DISTINCT", "") }} (distinct b.{{ col }}) as {{ alias }},
        {%- else %} {{ agg }} (b.{{ col }}) as {{ alias }},
        {%- endif -%}
        {%- do final_col_list.append(cte_name ~ '.' ~ alias) -%}
        {%- endif -%}
        {%- endfor -%}
        {%- endfor -%}
        count(1) as agg_row_count
    from {{ source_table }} a
    inner join
        {{ source_table }} b
        on {% for g in group_by -%} a.{{ g }} = b.{{ g }} and {% endfor %}
        1 = 1
    where
        {% if normalized_offset > 0 -%}
        b.{{ date }} <= dateadd({{ date_part }}, {{ normalized_offset }}, a.{{ date }})
        and b.{{ date }} >= a.{{ date }}
        {% else -%}
        b.{{ date }} >= dateadd({{ date_part }}, {{ normalized_offset }}, a.{{ date }})
        and b.{{ date }} <= a.{{ date }}
        {% endif %}
    group by {% for g in group_by %} a.{{ g }}, {% endfor -%} a.{{ date }}
)
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
{%- do final_col_list.append(cte_name3 ~ '.' ~ alias) -%},
{{ cte_name1 }} as (
    select
        {% for g in group_by -%} a.{{ g }}, {%- endfor %}
        a.{{ date }},
        b.{{ col }},
        count(1) as c
    from {{ source_table }} a
    inner join
        {{ source_table }} b
        on {% for g in group_by -%} a.{{ g }} = b.{{ g }} and {% endfor %}
        1 = 1
    where
        {% if normalized_offset > 0 -%}
        b.{{ date }} >= dateadd({{ date_part }}, {{ normalized_offset }}, a.{{ date }})
        and b.{{ date }} > a.{{ date }}
        {% else -%}
        b.{{ date }} >= dateadd({{ date_part }}, {{ normalized_offset }}, a.{{ date }})
        and b.{{ date }} <= a.{{ date }}
        {% endif %}
    group by {% for g in group_by %} a.{{ g }}, {% endfor -%} b.{{ col }}, a.{{ date }}
),
{{ cte_name2 }} as (
    select
        {%- for group_item in group_by %} {{ group_item }}, {%- endfor -%}
        {{ date }},
        {{ col }},
        c / sum(c) over (partition by {{ group_by | join(', ') }}, {{ date }}) as p
    from {{ cte_name1 }}
),
{{ cte_name3 }} as (
    select
        {%- for group_item in group_by %} {{ group_item }}, {%- endfor -%}
        {{ date }}, - sum(p * log(2, p)) as {{ alias }}
    from {{ cte_name2 }}
    group by {{ group_by | join(', ') }},{{ date }}
)
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
with
    dummy1 as (select null from {{ source_table }} where 1 = 0)
    {%- for offset in offsets -%}
    {{ create_cte_basic(group_by=group_by, offset=offset, date=date, date_part=date_part, aggregations=aggregations) }}
    {{ create_cte_entropy(group_by=group_by, offset=offset, date=date, date_part=date_part, entropy_aggs=entropy_aggs) }}
    {%- endfor -%},
    dummy2 as (select null from {{ source_table }} where 1 = 0)
select src.*, {{ final_col_list|join(', ') }}
from {{ source_table }} src
{% for cte in cte_list -%}
left outer join
    {{ cte }} on {{ cte }}.{{ date }} = src.{{ date }}
    {%- for g in group_by %} and {{ cte }}.{{ g }} = src.{{ g }} {% endfor -%}
{%- endfor -%}
