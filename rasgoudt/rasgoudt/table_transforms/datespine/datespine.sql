{% set row_count_query %}
select datediff({{ interval_type }}, '{{ start_timestamp }}'::timestamp_ntz, '{{ end_timestamp }}'::timestamp_ntz)
{% endset %}
{% set row_count_query_results = run_query(row_count_query) %}
{% set row_count = row_count_query_results[row_count_query_results.columns[0]][0] %}

with date_spine as (
    select
           row_number() over (order by null) as interval_id,
           dateadd(
               '{{ interval_type }}',
               interval_id - 1,
               '{{ start_timestamp }}'::timestamp_ntz) as ts_ntz_interval_start,
            dateadd(
               '{{ interval_type }}',
               interval_id,
               '{{ start_timestamp }}'::timestamp_ntz) as ts_ntz_interval_end
from table (generator(rowcount => {{ row_count }}))
    )
select  {{ source_table }}.*,
  date_spine.ts_ntz_interval_start as {{ date_col }}_spine_start,
  date_spine.ts_ntz_interval_end as {{ date_col }}_spine_end
from date_spine
left join {{ source_table }} on
    {{ source_table }}.{{ date_col }} >= date_spine.ts_ntz_interval_start
    and
    {{ source_table }}.{{ date_col }} < date_spine.ts_ntz_interval_end