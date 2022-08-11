{%- macro get_distinct_values(columns) -%}
    {%- set target_column = (metrics.keys()|list)[0] -%}
    {%- set aggregation_type = metrics[target_column][0] -%}
    {%- set distinct_val_query %}
        select
            concat(
                {%- for column in columns %}
                {{ column }}{{", '_', " if not loop.last}}
                {%- endfor %}
            ) as dimensions,
            {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct ' in aggregation_type|lower else ''}}{{ target_column }}) as vals
        from {{ source_table }}
            {{ filter_statement }}
        group by 1
        order by vals desc
        limit {{ max_num_groups + 1}}
    {%- endset -%}
    {%- set distinct_vals = run_query(distinct_val_query) -%}
    {%- for val in distinct_vals.itertuples() -%}
        {%- for column in distinct_vals.columns[:-1] -%}
            {{ val[column] }}{{'_' if not loop.last else ''}}
        {%- endfor -%}
        {{ '|$|' if not loop.last else ''}}
    {%- endfor %}
{%- endmacro -%}

{% macro calculate_time_metrics(metrics, time_dimension, dimensions, start_date, end_date, time_grain, source_table) %}

{%- if dimensions -%}
{%- set distinct_values = get_distinct_values(dimensions).split('|$|') -%}
{%- if distinct_values|length > max_num_groups %}
{%- set distinct_values = distinct_values[:-1] + ['_OtherGroup'] -%}
{%- endif -%}
{%- endif -%}

{%- set num_days = (end_date|todatetime - start_date|todatetime).days %}

with source_query as (
    select
        cast(date_trunc('day', cast({{ time_dimension }} as date)) as date) as date_day,
        {%- if dimensions %}
        concat(
            {%- for column in dimensions %}
            {{ column }}{{", '_', " if not loop.last}}
            {%- endfor %}
        ) as combined_dimensions,
        case
            when combined_dimensions in (
                {%- for val in distinct_values %}
                '{{ val }}'{{',' if not loop.last else ''}}
                {%- endfor %}
            ) then combined_dimensions
            {%- if 'None' in distinct_values %}
            when combined_dimensions is null then 'None'
            {%- endif %}
            else '_OtherGroup'
        end as dimensions,
        {%- endif %}
        {%- for column in metrics.keys() %}
        {{ column }}{{ ',' if not loop.last }}
        {%- endfor %}
    from {{ source_table }}
    {{ filter_statement }}
),
{%- if time_grain|lower == 'all'%}
spine as (
    select
        cast('{{ start_date }}' as timestamp_ntz) as {{ time_dimension }}_min,
        cast('{{ end_date }}' as timestamp_ntz) as {{ time_dimension }}_max
),
joined as (
    select *
    from source_query
        cross join spine
),
tidy_data as (
    select
        {{ time_dimension }}_min,
        {{ time_dimension }}_max, {{ '\n        dimensions,' if dimensions }}
        {%- for column, aggs in metrics.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}}{{ ',' if not (loop.last and oloop.last) }}
        {%- endfor %}
        {%- endfor %}
    from joined
    group by 1, 2{{ ', 3' if dimensions}}
)
{%- else %}
calendar as (
    select
            row_number() over (order by null) as interval_id,
            cast(dateadd(
                'day',
                interval_id-1,
                '{{ start_date }}'::timestamp_ntz) as date) as date_day,
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
{%- if dimensions %}
spine__time as (
        select
        date_{{ time_grain }} as period,
        date_day
        from calendar
),
spine__values__dimensions as (
    select distinct dimensions
    from source_query
),
spine as (
    select *
    from spine__time
        cross join spine__values__dimensions
),
{%- else %}
spine as (
        select
        date_{{ time_grain }} as period,
        date_day
        from calendar
),
{%- endif %}
joined as (
    select
        spine.period,{{ '\n        spine.dimensions,' if dimensions }}
        {%- for column, aggs in metrics.items() %}
        {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}} source_query.{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}},
        {%- endfor %}
        {%- endfor %}
        boolor_agg(source_query.date_day is not null) as has_data
    from spine
    left outer join source_query on source_query.date_day = spine.date_day
        {%- if dimensions %}
        and (source_query.dimensions = spine.dimensions
            or source_query.dimensions is null and spine.dimensions is null)
        {%- endif %}
    group by 1{{ ', 2' if dimensions }}
),
bounded as (
    select
        *,
            min(case when has_data then period end) over ()  as lower_bound,
            max(case when has_data then period end) over ()  as upper_bound
    from joined
),
tidy_data as (
    select
        cast(period as timestamp) as {{ time_dimension }}_min,
        {%- if time_grain|lower == 'quarter' %}
        dateadd('second', -1, dateadd('month',3, {{ time_dimension }}_min)) as {{ time_dimension }}_max,
        {%- else %}
        dateadd('second', -1, dateadd('{{ time_grain }}',1, {{ time_dimension }}_min)) as {{ time_dimension }}_max,
        {%- endif %}{{ '\n        dimensions,' if dimensions }}
        {%- for column, aggs in metrics.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
        {{ cleanse_name(aggregation_type + '_' + column)}}{{ ',' if not (loop.last and oloop.last) }}
        {%- endfor %}
        {%- endfor %}
    from bounded
    where period >= lower_bound
    and period <= upper_bound
    order by 1, 2{{ ', 3' if dimensions }}
) select * from tidy_data
{%- endif %}
{% endmacro %}


{% macro calculate_binned_metrics(metrics, x_axis, dimensions, bucket_count, source_table) %}
{% set bucket_count = num_buckets if num_buckets is defined else 200 %}
with axis_range as (
    select
        min({{ x_axis }}) - 1 as min_val,
        max({{ x_axis }}) + 1 as max_val
    from {{ source_table }}
    where {{ x_axis }} is not null
),
edges as (
    select
        min_val,
        max_val,
        (min_val-max_val) val_range,
        ((max_val-min_val)/{{ bucket_count }}) bucket_size
    from axis_range
),
buckets as (
    select
        {%- for column in dimensions %}
        {{ column }},
        {%- endfor %}
        min_val,
        max_val,
        bucket_size,
        cast({{ x_axis }} as float) as col_a_val,
        width_bucket(col_a_val, min_val, max_val, {{ bucket_count }}) as bucket,
        {%- for column in metrics.keys() %}
        {{ column }}{{ ',' if not loop.last }}
        {%- endfor %}
    from
        {{ source_table }}
        cross join edges
    {{ filter_statement }}
),
source_query as (
    select
        bucket,
        {%- if dimensions %}
        concat(
            {%- for column in dimensions %}
            {{ column }}{{", '_', " if not loop.last}}
            {%- endfor %}
        ) as combined_dimensions,
        case
            when combined_dimensions in (
                {%- for val in distinct_values %}
                '{{ val }}'{{',' if not loop.last else ''}}
                {%- endfor %}
            ) then combined_dimensions
            {%- if 'None' in distinct_values %}
            when combined_dimensions is null then 'None'
            {%- endif %}
            else '_OtherGroup'
        end as dimensions,
        {%- endif %}
        {%- for column in metrics.keys() %}
        {{ column }}{{ ',' if not loop.last }}
        {%- endfor %}
    from buckets
),
{%- if dimensions %}
bucket_spine as (
    select
        row_number() over (order by null) as bucket
    from table (generator(rowcount => {{ bucket_count }}))
),
spine__values__dimensions as (
    select distinct dimensions from source_query
),
spine as (
    select * from bucket_spine
        cross join spine__values__dimensions
),
{%- else %}
spine as (
    select
        row_number() over (order by null) as bucket
    from table (generator(rowcount => {{ bucket_count }}))
),
{%- endif %}
joined as (
    select {{ '\n        spine.dimensions,' if dimensions}}
        spine.bucket,
        {%- for column, aggs in metrics.items() %}
        {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}source_query.{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}},
        {%- endfor %}
        {%- endfor %}
        boolor_agg(source_query.bucket is not null) as has_data
    from spine
    left outer join source_query on source_query.bucket = spine.bucket
        {%- if dimensions %}
        and (source_query.dimensions = spine.dimensions
            or source_query.dimensions is null and spine.dimensions is null)
        {%- endif %}
    group by 1{{ ', 2' if dimensions }}
),
tidy_data as (
    select
        min_val+((bucket-1)*bucket_size) as {{ x_axis }}_min,
        min_val+(bucket*bucket_size) as {{ x_axis }}_max, {{ '\n        dimensions,' if dimensions }}
        {%- for column, aggs in metrics.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
        {{ cleanse_name(aggregation_type + '_' + column)}}{{ '' if loop.last and oloop.last else ',' }}
        {%- endfor %}
        {%- endfor %}
    from joined
        cross join edges
)
{% endmacro %}
