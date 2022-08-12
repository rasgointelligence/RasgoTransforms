{% if start_timestamp is not defined or end_timestamp is not defined -%}
{%- set min_max_query -%}
select min(cast({{ date_col }} as date)) min_date, max(cast({{ date_col }} as date)) max_date from {{ source_table }}
{% endset -%}
{% set min_max_query_result = run_query(min_max_query) -%}
{% if min_max_query_result is none -%}
{{ raise_exception('start_timstamp and end_timestamp must be provided when no Data Warehouse connection is available') }}
{% endif -%}
{% endif -%}
{% if start_timestamp is defined -%} {% set min_date = start_timestamp -%}
{% else -%}
{% set min_date = min_max_query_result[min_max_query_result.columns[0]][0] -%}
{% endif -%}
{% if end_timestamp is defined -%} {% set max_date = end_timestamp -%}
{% else -%}
{% set max_date = min_max_query_result[min_max_query_result.columns[1]][0] -%}
{% endif -%}
{% set row_count = (max_date|string|todatetime - min_date|string|todatetime).days + 1 -%}

with
    global_spine as (
        select
            row_number() over (order by null) as interval_id,
            dateadd(
                '{{ interval_type }}',
                (interval_id - 1),
                '{{ min_date }}'::timestamp_ntz
            ) as spine_start,
            dateadd(
                '{{ interval_type }}', interval_id, '{{ min_date }}'::timestamp_ntz
            ) as spine_end
        from table(generator(rowcount => {{ row_count }}))
    ),
    groups as (
        select
            {% for col in group_by -%} {{ col }}, {%- endfor %}
            min({{ date_col }}) as local_start,
            max({{ date_col }}) as local_end
        from {{ source_table }}
        group by
            {% for col in group_by -%}
            {{ col }}{{ ', ' if not loop.last else ' ' }}
            {%- endfor %}
    ),
    group_spine as (
        select
            {% for col in group_by -%} {{ col }}, {%- endfor %}
            spine_start as group_start,
            spine_end as group_end
        from groups g
        cross join
            lateral(
                select spine_start, spine_end
                from global_spine s
                {% if group_bounds == 'local' %}
                where s.spine_start between g.local_start and g.local_end
                {% elif group_bounds == 'mixed' %} where s.spine_start >= g.local_start
                {% endif %}
            )
    )

select
    {% for col in group_by -%} g.{{ col }} as group_by_{{ col }}, {%- endfor %}
    group_start,
    group_end,
    t.*
from group_spine g
left join
    {{ source_table }} t
    on {{ date_col }} >= g.group_start
    and {{ date_col }} < g.group_end
    {% for col in group_by %} and g.{{ col }} = t.{{ col }} {%- endfor %}
