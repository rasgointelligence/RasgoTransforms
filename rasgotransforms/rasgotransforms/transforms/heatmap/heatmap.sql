{%- if num_buckets is not defined -%} {%- set bucket_count = 100 -%}
{%- else -%} {%- set bucket_count = num_buckets -%}
{%- endif -%}
with
    axis_range as (
        -- Use a user-defined axis column to calculate the min & max of the axis (and
        -- buckets on the axis)
        select
            min({{ x_axis }}) -1 as min_x_val,
            max({{ x_axis }}) + 1 as max_x_val,
            min({{ y_axis }}) -1 as min_y_val,
            max({{ y_axis }}) + 1 as max_y_val
        from {{ source_table }}
        where {{ x_axis }} is not null
    ),
    edges as (
        select
            min_x_val,
            max_x_val,
            (min_x_val - max_x_val) x_val_range,
            ((max_x_val - min_x_val) /{{ bucket_count }}) x_bucket_size,
            min_y_val,
            max_y_val,
            (min_y_val - max_y_val) y_val_range,
            ((max_y_val - min_y_val) /{{ bucket_count }}) y_bucket_size
        from axis_range
    ),
    buckets as (
        select
            -- Assigns a bucket to each value of each column in user's column list
            -- Row count of result set should match the row count of the raw table
            min_x_val,
            max_x_val,
            x_bucket_size,
            min_y_val,
            max_y_val,
            y_bucket_size,
            cast({{ x_axis }} as float) as col_x_val,
            width_bucket(
                col_x_val, min_x_val, max_x_val, {{ bucket_count }}
            ) as col_x_bucket,
            cast({{ y_axis }} as float) as col_y_val,
            width_bucket(
                col_y_val, min_y_val, max_y_val, {{ bucket_count }}
            ) as col_y_bucket
        from {{ source_table }}
        cross join
            edges
            {%- if filters is defined and filters %}
            {% for filter_block in filters %}
            {%- set oloop = loop -%}
            {{ 'WHERE ' if oloop.first else ' AND ' }}
            {%- if filter_block is not mapping -%} {{ filter_block }}
            {%- else -%}
            {%- if filter_block['operator'] == 'CONTAINS' -%}
            {{ filter_block['operator'] }} (
                {{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }}
            )
            {%- else -%}
            {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
            {%- endif -%}
            {%- endif -%}
            {%- endfor -%}
            {%- endif -%}
    )
-- Run final aggregates on the buckets
select
    min_x_val + ((col_x_bucket -1) * x_bucket_size) as {{ x_axis }}_min,
    min_x_val + (col_x_bucket * x_bucket_size) as {{ x_axis }}_max,
    min_y_val + ((col_y_bucket -1) * y_bucket_size) as {{ y_axis }}_min,
    min_y_val + (col_y_bucket * y_bucket_size) as {{ y_axis }}_max,
    count(col_y_val) + count(col_x_val) as density

from buckets
where {{ x_axis }}_min is not null and {{ y_axis }}_min is not null
group by 1, 2, 3, 4
order by 1, 3
