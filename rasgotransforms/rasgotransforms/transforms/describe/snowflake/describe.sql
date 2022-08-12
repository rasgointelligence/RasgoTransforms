{%- set names_types_list = get_columns(source_table) -%}


{%- for key, value in names_types_list.items() -%}
{% if (value == 'NUMBER' or 'FLOAT' in value or 'INT' in value) %}
select
    '{{ key }}' as feature,
    '{{ value }}' as dtype,
    count(col) as count,
    sum(case when col is null then 1 else 0 end) as null_count,
    count(distinct col) as unique_count,
    mode(col)::string as most_frequent,
    avg(col) as mean,
    stddev(col) as std_dev,
    min(col)::string as min,
    percentile_cont(0.25) within group (order by col) as _25_percentile,
    percentile_cont(0.5) within group (order by col) as _50_percentile,
    percentile_cont(0.75) within group (order by col) as _75_percentile,
    max(col)::string as max
from
    (select {{ key }} as col from {{ source_table }})
    {{ "UNION ALL " if not loop.last else "" }}
{% else %}
select
    '{{ key }}' as feature,
    '{{ value }}' as dtype,
    count(col) as count,
    sum(case when col is null then 1 else 0 end) as null_count,
    count(distinct col) as unique_count,
    mode(col)::string as most_frequent,
    null as mean,
    null as std_dev,
    min(col)::string as min,
    null as _25_percentile,
    null as _50_percentile,
    null as _75_percentile,
    max(col)::string as max
from
    (select {{ key }} as col from {{ source_table }})
    {{ "UNION ALL " if not loop.last else "" }}
{% endif -%}
{%- endfor -%}
