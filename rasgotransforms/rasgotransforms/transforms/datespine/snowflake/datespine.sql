{% if start_timestamp is not defined or end_timestamp is not defined -%}
{%- set min_max_query -%}
select min(cast({{ date_col }} as date)) min_date, max(cast({{ date_col }} as date)) max_date from {{ source_table }}
{% endset -%}
{% set min_max_query_result = run_query(min_max_query) -%}
{% if min_max_query_result is none -%}
{{ raise_exception('start_timstamp and end_timestamp must be provided when no Data Warehouse connection is available')}}
{% endif -%}
{% endif -%}
{% if start_timestamp is defined -%}
    {% set min_date = start_timestamp -%}
{% else -%}
    {% set min_date = min_max_query_result[min_max_query_result.columns[0]][0] -%}
{% endif -%}
{% if  end_timestamp is defined -%}
    {% set max_date = end_timestamp -%}
{% else -%}
    {% set max_date = min_max_query_result[min_max_query_result.columns[1]][0] -%}
{% endif -%}
{% set num_days = (max_date|string|todatetime - min_date|string|todatetime).days + 1 -%}
with calendar as (
    select
        row_number() over (order by null) as interval_id,
        cast(dateadd(
            'day',
            interval_id-1,
            '{{ min_date }}'::timestamp_ntz) as date) as date_day,
        cast(date_trunc('week', date_day) as date) as date_week,
        cast(date_trunc('month', date_day) as date) as date_month,
        case
            when month(date_day) in (1, 2, 3) then date_from_parts(year(date_day), 1, 1)
            when month(date_day) in (4, 5, 6) then date_from_parts(year(date_day), 4, 1)
            when month(date_day) in (7, 8, 9) then date_from_parts(year(date_day), 7, 1)
            when month(date_day) in (10, 11, 12) then date_from_parts(year(date_day), 10, 1)
        end as date_quarter,
        cast(date_trunc('year', date_day) as date) as date_year
    from table (generator(rowcount => {{ num_days }}))
),
spine as (
    select distinct date_{{ interval_type }} as period
    from calendar
)
select
    cast(spine.period as timestamp) as {{ date_col }}_SPINE_START,
    {%- if interval_type|lower == 'quarter' %}
    dateadd('second', -1, dateadd('month',3, {{ date_col }}_SPINE_START)) as {{ date_col }}_SPINE_END,
    {%- else %}
    dateadd('second', -1, dateadd('{{ interval_type }}',1, {{ date_col }}_SPINE_START)) as {{ date_col }}_SPINE_END,
    {%- endif %}
    {{ source_table }}.*
from spine
left outer join {{ source_table }} on 
    cast(date_trunc('{{ interval_type }}', cast({{ source_table}}.{{ date_col }} as date)) as date) = spine.period