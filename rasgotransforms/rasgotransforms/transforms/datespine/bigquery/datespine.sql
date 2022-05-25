{% set min_max_query %}
select min(cast({{ date_col }} as date)) min_date, max(cast({{ date_col }} as date)) max_date from {{ source_table }}
{% endset %}
{% set min_max_query_result = run_query(min_max_query) %}
{% if start_timestamp is defined %}
    {% set min_date = start_timestamp %}
{% else %}
    {% set min_date = min_max_query_result[min_max_query_result.columns[0]][0] %}
{% endif %}
{% if  end_timestamp is defined %}
    {% set max_date = end_timestamp %}
{% else %}
    {% set max_date = min_max_query_result[min_max_query_result.columns[1]][0] %}
{% endif %}
{% set row_count_query %}
select DATE_DIFF(cast('{{ min_date }}' as date), cast('{{ max_date }}' as date), {{ interval_type }})
{% endset %}
{% set row_count_query_results = run_query(row_count_query) %}
{%- set row_count = row_count_query_results[row_count_query_results.columns[0]][0] -%}
with date_spine as (
    select
           row_number() over (order by null) as interval_id,
            DATE_ADD(
                cast('{{ min_date }}' as timestamp),
                INTERVAL interval_id - 1 {{ interval_type }}
                ) as ts_ntz_interval_start,
            DATE_ADD(
                cast('{{ min_date }}' as timestamp)
                INTERVAL interval_id {{ interval_type }}
               ) as ts_ntz_interval_end
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