{%- set flatten = flatten if flatten is defined else true -%}
{%- set max_num_groups = max_num_groups if max_num_groups is defined else 10 -%}
{%- set bucket_count = num_buckets if num_buckets is defined else 200 -%}
{%- set filters = filters if filters is defined else [] -%}
{%- set axis_type_dict = get_columns(source_table) -%}
{%- set axis_type_response = axis_type_dict[x_axis].upper() -%}
{%- set group_by = [group_by] if group_by is defined and group_by is string else group_by-%}
{%- if 'DATE' in axis_type_response or 'TIME' in axis_type_response -%}
  {%- set axis_type = "date" -%}
{%- elif 'NUM' in axis_type_response or 'FLOAT' in axis_type_response or 'INT' in axis_type_response or 'DECIMAL' in axis_type_response or 'DOUBLE' in axis_type_response or 'REAL' in axis_type_response -%}
    {%- set axis_type = "numeric" -%}
{%- elif 'BINARY' in axis_type_response or 'TEXT' in axis_type_response or 'BOOLEAN' in axis_type_response or 'CHAR' in axis_type_response or 'STRING' in axis_type_response or 'VARBINARY' in axis_type_response -%}
    {%- set axis_type = "categorical" -%}
{%- else -%}
    {{ raise_exception('The column selected as an axis is not categorical, numeric, or datetime. Please choose an axis that is any of these data types and recreate the transform.') }}
{%- endif -%}
{%- if axis_type == 'date' -%}
{%- if timeseries_options -%}
{%- set start_date = '2010-01-01' if not timeseries_options.start_date else timeseries_options.start_date -%}
{%- set end_date = '2030-01-01' if not timeseries_options.end_date else timeseries_options.end_date -%}
{%- set time_grain = 'day' if not timeseries_options.time_grain else timeseries_options.time_grain -%}
{%- else -%}
{{ raise_exception("Parameter 'timeseries_options' must be given when 'x_axis' is a column of type datetime")}}
{%- endif -%}
{%- set num_days = (end_date|string|todatetime - start_date|string|todatetime).days + 1 -%}
{%- do filters.append({'columnName': x_axis, 'operator': '>=', 'comparisonValue': "'" + start_date + "'" }) -%}
{%- do filters.append({'columnName': x_axis, 'operator': '<=', 'comparisonValue': "'" + end_date + "'" }) -%}
{%- endif -%}

{%- set filter_statement -%}
    where true
        {%- for filter in filters %}
        {%- if filter is not mapping %}
        and {{ filter }}
        {%- elif filter.operator|upper == 'CONTAINS' %}
        and REGEXP_CONTAINS({{ filter.columnName }}, {{ filter.comparisonValue }})
        {%- else %}
        and {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
        {%- endif %}
        {%- endfor %}
{%- endset -%}

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

{%- if group_by -%}
{%- set distinct_values = get_distinct_values(group_by).split('|$|') -%}
{%- if distinct_values|length > max_num_groups %}
{%- set distinct_values = distinct_values[:-1] + ['_OtherGroup'] -%}
{%- endif -%}
{%- endif -%}

with combined_dimensions as (
    select *,
        concat(''{{',' if group_by}}
            {%- for column in group_by %}
            {{ column }}{{", '_', " if not loop.last}}
            {%- endfor %}
        ) as dimensions
    from {{ source_table }}
),
{%- if axis_type == 'date' %}
source_query as (
    select
        cast(date_trunc(cast({{ x_axis }} as date), day) as date) as date_day,
        {%- if group_by %}
        case
            when dimensions in (
                    {%- for val in distinct_values %}
                    '{{ val }}'{{',' if not loop.last else ''}}
                    {%- endfor %}
                ) then dimensions
            {%- if 'None' in distinct_values %}
            when dimensions is null then 'None'
            {%- endif %}
            else '_OtherGroup'
        end as dimensions,
        {%- endif %}
        {%- for column in metrics.keys() %}
        {{ column }}{{ ',' if not loop.last }}
        {%- endfor %}
    from combined_dimensions
    {{ filter_statement }}
),
{%- if time_grain|lower == 'all'%}
spine as (
    select
        cast('{{ start_date }}' as timestamp) as {{ x_axis }}_min,
        cast('{{ end_date }}' as timestamp) as {{ x_axis }}_max
),
joined as (
    select *
    from source_query
        cross join spine
),
tidy_data as (
    select
        {{ x_axis }}_min,
        {{ x_axis }}_max, {{ '\n        dimensions,' if group_by }}
        {%- for column, aggs in metrics.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}}{{ ',' if not (loop.last and oloop.last) }}
        {%- endfor %}
        {%- endfor %}
    from joined
    group by 1, 2{{ ', 3' if group_by}}
)
{%- else %}
calendar as (
  select
    date_day,
    date_trunc(date_day, week) as date_week,
    date_trunc(date_day, month) as date_month,
    date_trunc(date_day, quarter) as date_quarter,
    date_trunc(date_day, year) as date_year
    from unnest(generate_date_array('{{ start_date }}', '{{ end_date }}')) as date_day
),
{%- if group_by %}
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
        spine.period,{{ '\n        spine.dimensions,' if group_by }}
        {%- for column, aggs in metrics.items() %}
        {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}} source_query.{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}},
        {%- endfor %}
        {%- endfor %}
        logical_or(source_query.date_day is not null) as has_data
    from spine
    left outer join source_query on source_query.date_day = spine.date_day
        {%- if group_by %}
        and (source_query.dimensions = spine.dimensions
            or source_query.dimensions is null and spine.dimensions is null)
        {%- endif %}
    group by 1{{ ', 2' if group_by }}
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
        cast(period as timestamp) as {{ x_axis }}_min,
        {%- if time_grain|lower == 'quarter' %}
        cast(date_add(period, INTERVAL 3 month) as timestamp) as {{ x_axis }}_max,
        {%- else %}
        cast(date_add(period, INTERVAL 1 {{ time_grain }}) as timestamp) as {{ x_axis }}_max,
        {%- endif %}{{ '\n        dimensions,' if group_by }}
        {%- for column, aggs in metrics.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
        {{ cleanse_name(aggregation_type + '_' + column)}}{{ ',' if not (loop.last and oloop.last) }}
        {%- endfor %}
        {%- endfor %}
    from bounded
    where period >= lower_bound
    and period <= upper_bound
    order by 1, 2{{ ', 3' if group_by }}
)
{%- endif %}

{%- elif axis_type == 'numeric' %}

axis_range as (
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
        dimensions,
        min_val,
        max_val,
        bucket_size,
        cast({{ x_axis }} as numeric) as col_a_val,
        range_bucket(cast({{ x_axis }} as numeric), generate_array(min_val, max_val, (max_val - min_val)/{{ bucket_count }})) as bucket,
        {%- for column in metrics.keys() %}
        {{ column }}{{ ',' if not loop.last }}
        {%- endfor %}
    from
        combined_dimensions
        cross join edges
    {{ filter_statement }}
),
source_query as (
    select
        bucket,
        {%- if group_by %}
        case
            when dimensions in (
                    {%- for val in distinct_values %}
                    '{{ val }}'{{',' if not loop.last else ''}}
                    {%- endfor %}
                ) then dimensions
            {%- if 'None' in distinct_values %}
            when dimensions is null then 'None'
            {%- endif %}
            else '_OtherGroup'
        end as dimensions,
        {%- endif %}
        {%- for column in metrics.keys() %}
        {{ column }}{{ ',' if not loop.last }}
        {%- endfor %}
    from buckets
),
{%- if group_by %}
bucket_spine as (
    select bucket 
    from unnest(generate_array(1, {{ bucket_count }})) as bucket
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
    select bucket 
    from unnest(generate_array(1, {{ bucket_count }})) as bucket
),
{%- endif %}
joined as (
    select {{ '\n        spine.dimensions,' if group_by}}
        spine.bucket,
        {%- for column, aggs in metrics.items() %}
        {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}source_query.{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}},
        {%- endfor %}
        {%- endfor %}
        logical_or(source_query.bucket is not null) as has_data
    from spine
    left outer join source_query on source_query.bucket = spine.bucket
        {%- if group_by %}
        and (source_query.dimensions = spine.dimensions
            or source_query.dimensions is null and spine.dimensions is null)
        {%- endif %}
    group by 1{{ ', 2' if group_by }}
),
tidy_data as (
    select
        min_val+((bucket-1)*bucket_size) as {{ x_axis }}_min,
        min_val+(bucket*bucket_size) as {{ x_axis }}_max, {{ '\n        dimensions,' if group_by }}
        {%- for column, aggs in metrics.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
        {{ cleanse_name(aggregation_type + '_' + column)}}{{ '' if loop.last and oloop.last else ',' }}
        {%- endfor %}
        {%- endfor %}
    from joined
        cross join edges
)

{%- elif axis_type == 'categorical' -%}
source_query as (
    select
        {{ x_axis }},
        {%- if group_by %}
        case
            when dimensions in (
                    {%- for val in distinct_values %}
                    '{{ val }}'{{',' if not loop.last else ''}}
                    {%- endfor %}
                ) then dimensions
            {%- if 'None' in distinct_values %}
            when dimensions is null then 'None'
            {%- endif %}
            else '_OtherGroup'
        end as dimensions,
        {%- endif %}
        {%- for column in metrics.keys() %}
        {{ column }}{{ ',' if not loop.last }}
        {%- endfor %}
    from combined_dimensions
    {{ filter_statement }}
),
tidy_data as (
    select
        {%- if not group_by or not flatten %}
        {{ x_axis }},
        {%- else %}
        {{ x_axis }} as {{ x_axis }}_min,
        {{ x_axis }} as {{ x_axis }}_max,
        {%- endif %}{{ '\n        dimensions,' if group_by}}
        {%- for column, aggs in metrics.items() %}
        {%- set oloop = loop -%}
        {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}}{{ '' if loop.last and oloop.last else ',' }}
        {%- endfor -%}
        {%- endfor %}
    from source_query
    group by 1{{ ', 2' if group_by }}{{ ', 3' if group_by and flatten }}
)
{%- endif -%}
{%- if not group_by or not flatten %}
select * from tidy_data order by 1 {{ x_axis_order if x_axis_order }}
{%- else -%}
,
{% set metric_names = [] -%}
{%- set column_names = [] -%}
{%- for column, aggs in metrics.items() -%}
{%- for aggregation_type in aggs -%}
{%- set metric_name = cleanse_name(aggregation_type + '_' + column) -%}
{%- do metric_names.append(metric_name) %}
pivoted__{{ metric_name }} as (
    select * from (
        select
            {{ x_axis }}_min as x_min_{{ metric_name }},
            {{ x_axis }}_max as x_max_{{ metric_name }},
            {{ metric_name }},
            dimensions
        from tidy_data
    )
    pivot (
        sum( {{ metric_name }} ) as {{ metric_name }}
        for dimensions in (
            {%- for val in distinct_values %}
            {%- set column_name = metric_name + '_' + (val|string) -%}
            {%- do column_names.append(column_name) -%}
            {%- if val is string -%}
            '{{ val }}'
            {%- else -%}
            {{ val }}
            {%- endif -%}
            {{', ' if not loop.last else ''}}
            {%- endfor -%}
        )
    )
),
{%- endfor %}
{%- endfor %}
pivoted as (
    select *
    from pivoted__{{ metric_names[0] }}
        {%- for i in range(1, metric_names|length) %}
        left join pivoted__{{ metric_names[i] }}
            on x_min_{{ metric_names[0] }} = x_min_{{ metric_names[i] }}
            and x_max_{{ metric_names[0] }} = x_max_{{ metric_names[i] }}
        {%- endfor %}
)
select
    {%- if axis_type == 'categorical' %}
    x_min_{{ metric_names[0] }} as {{ x_axis }},
    {%- else %}
    x_min_{{ metric_names[0] }} as {{ x_axis }}_min,
    x_max_{{ metric_names[0] }} as {{ x_axis }}_max,
    {%- endif %}
    {%- for column_name in column_names %}
    {{ column_name }}{{ ',' if not loop.last }}
    {%- endfor %}
from pivoted order by 1 {{ x_axis_order if x_axis_order }}
{%- endif %}