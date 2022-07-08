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
    {% set min_date = (start_timestamp|todatetime).date() -%}
{% else -%}
    {% set min_date = min_max_query_result[min_max_query_result.columns[0]][0] -%}
{% endif -%}
{% if  end_timestamp is defined -%}
    {% set max_date = (end_timestamp|todatetime).date() -%}
{% else -%}
    {% set max_date = min_max_query_result[min_max_query_result.columns[1]][0] -%}
{% endif -%}
with calendar as (
  select
    date_day,
    date_trunc(date_day, week) as date_week,
    date_trunc(date_day, month) as date_month,
    date_trunc(date_day, quarter) as date_quarter,
    date_trunc(date_day, year) as date_year
    from unnest(generate_date_array('{{ min_date }}', '{{ max_date }}')) as date_day
),
spine as (
    select distinct date_{{ interval_type }} as period
    from calendar
)
select
    cast(spine.period as timestamp) as {{ date_col }}_SPINE_START,
    timestamp_add(cast(date_add(spine.period, INTERVAL 1 {{ interval_type }}) as timestamp), INTERVAL -1 second) as {{ date_col }}_SPINE_END,
    st.*
from spine
left outer join {{ source_table }} st on 
    cast(date_trunc(cast(st.{{ date_col }} as date), {{ interval_type }}) as date) = spine.period
