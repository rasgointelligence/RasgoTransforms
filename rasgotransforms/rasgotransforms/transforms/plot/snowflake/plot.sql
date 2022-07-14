{%- set start_date = '2010-01-01' if not start_date else start_date -%}
{%- set end_date = '2030-01-01' if not end_date else end_date -%}
{%- set num_days = (end_date|string|todatetime - start_date|string|todatetime).days + 1 -%}
{%- set alias = 'metric_value' if not alias else alias -%}
{%- set distinct = true if 'distinct' in aggregation_type|lower else false -%}
{%- set aggregation_type = aggregation_type|upper|replace('_', '')|replace('DISTINCT', '')|replace('MEAN', 'AVG') -%}
{%- set flatten = flatten if flatten is defined else true -%}
{%- set max_num_groups = max_num_groups if max_num_groups is defined else 10 -%}
{%- set bucket_count = bucket_count if bucket_count is defined else 200 -%}
{%- set filters = filters if filters is defined else [] -%}
{%- set axis_type_dict = get_columns(source_table) -%}
{%- set axis_type_response = axis_type_dict[time_dimension.upper()].upper() -%}
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
{%- do filters.append({'columnName': time_dimension, 'operator': '>=', 'comparisonValue': "'" + start_date + "'" }) -%}
{%- do filters.append({'columnName': time_dimension, 'operator': '<=', 'comparisonValue': "'" + end_date + "'" }) -%}
{%- endif -%}

{%- macro get_distinct_values(column) -%}
    {%- set distinct_val_query %}
        select
            to_char({{ column }}) as {{ column }},
            {{ aggregation_type }}({{ 'distinct ' if distinct else ''}}{{ target_expression}}) as vals
        from {{ source_table }} 
        where true
            {%- for filter in filters %}
            and {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
            {%- endfor %}
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

{%- if dimension -%}
{%- set distinct_values = get_distinct_values(dimension).split('|$|') -%}
{%- if distinct_values|length > max_num_groups %}
{%- set distinct_values = distinct_values[:-1] + ['Other'] -%}
{%- endif -%}
{%- endif -%}

{%- if axis_type == 'date' %}
with source_query as (
    select
        cast(date_trunc('day', cast({{ time_dimension }} as date)) as date) as date_day,
        {%- if dimension %}
        case
            when to_char({{ dimension }}) in (
                {%- for val in distinct_values %}
                '{{ val }}'{{',' if not loop.last else ''}}
                {%- endfor %}
            ) then to_char({{ dimension }})
            {%- if 'None' in distinct_values %}
            when {{ dimension }} is null then 'None'
            {%- endif %}
            else 'Other'
        end as {{ dimension }},
        {%- endif %}
        {%- for column in metrics.keys() %}
        {{ column }}{{ ',' if not loop.last }}
        {%- endfor %}
    from {{ source_table }}
    where true
        {%- for filter in filters %}
        and {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
        {%- endfor %}
),
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
{%- if dimension %}
spine__time as (
        select
        date_{{ time_grain }} as period,
        date_day
        from calendar
),
spine__values__{{ dimension }} as (
    select distinct {{ dimension }}
    from source_query
),
spine as (
    select *
    from spine__time
        cross join spine__values__{{ dimension }}
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
        spine.period,
        {%- if dimension %}
        spine.{{ dimension }},
        {%- endif %}
        {%- for column, aggs in metrics.items() %}
        {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}} source_query.{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}},
        {%- endfor %}
        {%- endfor %}
        boolor_agg(source_query.date_day is not null) as has_data
    from spine
    left outer join source_query on source_query.date_day = spine.date_day
        {%- if dimension %}
        and (source_query.{{ dimension }} = spine.{{ dimension }}
            or source_query.{{ dimension }} is null and spine.{{ dimension }} is null)
        {%- endif %}
    group by 1{{ ', 2' if dimension }}
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
        cast(period as timestamp) as x_min,
        {%- if time_grain|lower == 'quarter' %}
        dateadd('second', -1, dateadd('month',3, x_min)) as x_max,
        {%- else %}
        dateadd('second', -1, dateadd('{{ time_grain }}',1, x_min)) as x_max,
        {%- endif %}
        {%- if dimension %}
        {{ dimension }},
        {%- endif %}
        {%- for column, aggs in metrics.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
        {{ cleanse_name(aggregation_type + '_' + column)}}{{ ',' if not (loop.last and oloop.last) }}
        {%- endfor %}
        {%- endfor %}
    from bounded
    where period >= lower_bound
    and period <= upper_bound
    order by 1, 2{{ ', 3' if dimension }}
)

{%- elif axis_type == 'numeric' %}

with axis_range as (
    select
        min({{ time_dimension }}) - 1 as min_val,
        max({{ time_dimension }}) + 1 as max_val
    from {{ source_table }}
    where {{ time_dimension }} is not null
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
        min_val,
        max_val,
        bucket_size,
        cast({{ time_dimension }} as float) as col_a_val,
        width_bucket(col_a_val, min_val, max_val, {{ bucket_count }}) as bucket,
        {{ target_expression }} as property_to_aggregate
        {{ ', ' + dimension if dimension else ''}}
    from
        {{ source_table }}
        cross join edges
    where true
        {%- for filter in filters %}
        and {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
        {%- endfor %}
),
source_query as (
    select 
        bucket, 
        property_to_aggregate{{ ', ' if dimension }}
        {{ dimension if dimension }}
    from buckets
),
{%- if dimension %}
bucket_spine as (
    select
        row_number() over (order by null) as bucket
    from table (generator(rowcount => {{ bucket_count }}))
), spine__values__{{ dimension }} as (
    select distinct {{ dimension }} from {{ source_table }}
), spine as (
    select * from bucket_spine
        cross join spine__values__{{ dimension }}
),
{%- else %}
spine as (
    select
        row_number() over (order by null) as bucket
    from table (generator(rowcount => {{ bucket_count }}))
),
{%- endif %}
joined as (
    select
        spine.bucket,
        {%- if dimension %}
        spine.{{ dimension }},
        {%- endif %}
        {{ aggregation_type }}({{ 'distinct ' if distinct else ''}}source_query.property_to_aggregate) as {{ alias }},
        boolor_agg(source_query.bucket is not null) as has_data
    from spine
    left outer join source_query on source_query.bucket = spine.bucket
        {%- if dimension %}
        and (source_query.{{ dimension }} = spine.{{ dimension }}
            or source_query.{{ dimension }} is null and spine.{{ dimension }} is null)
        {%- endif %}
    group by 1{{ ', 2' if dimension }}
), tidy_data as (
    select
        min_val+((bucket-1)*bucket_size) as x_min,
        min_val+(bucket*bucket_size) as x_max,
        {{ alias }}{{ '\n\t\t, ' + dimension if dimension else ''}}
    from joined
        cross join edges
)

{%- endif -%}
{%- if axis_type in ['date', 'numeric'] -%}
{%- if not dimension or not flatten %}
select * from tidy_data order by period_min
{%- else -%}
,
{% set metric_names = [] -%}
{%- set column_names = [] -%}
{%- for column, aggs in metrics.items() -%}
{%- for aggregation_type in aggs -%}
{%- set metric_name = cleanse_name(aggregation_type + '_' + column) -%}
{%- do metric_names.append(metric_name) -%}
pivoted__{{ metric_name }} as (
    select
        x_min_{{ metric_name }},
        x_max_{{ metric_name }},
        {% for val in distinct_values -%}
        {%- set column_name = cleanse_name(val) + '_' + metric_name -%}
        {%- do column_names.append(column_name) -%}
        {{ column_name }}{{',' if not loop.last else ''}}
        {%- endfor %}
    from (
        select 
            x_min,
            x_max,
            {{ metric_name }},
            {{ dimension }}
        from tidy_data
    )
    pivot (
        sum({{ metric_name }}) for {{ dimension }} in (
            {% for val in distinct_values -%}
            '{{ val }}'{{',' if not loop.last else ''}}
            {%- endfor %}
        )
    ) as p (
        x_min_{{ metric_name }},
        x_max_{{ metric_name }},
        {% for val in distinct_values -%}
        {{ cleanse_name(val) + '_' + metric_name }}{{',' if not loop.last else ''}}
        {%- endfor %}
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
    x_min_{{ metric_names[0] }} as x_min,
    x_max_{{ metric_names[0] }} as x_max,
    {%- for column_name in column_names %}
    {{ column_name }}{{ ',' if not loop.last }}
    {%- endfor %}
from pivoted order by x_min
{%- endif %}

{%- else %}

{%- if distinct_vals is defined and distinct_vals %}
    WITH TEMP AS (
        SELECT
        {{ x_axis }}
        {% for col, aggs in metrics.items() %}
            {% for distinct_val in distinct_vals %}
                ,CASE WHEN {{ group_by }} = '{{ distinct_val }}' THEN {{ col }} END AS {{ cleanse_name(distinct_val) }}_{{ col }}
            {%- endfor %}
        {%- endfor %}
        FROM {{ source_table }}
    )
    SELECT
    {{ x_axis }}
    {% for col, aggs in metrics.items() %}
        {% for agg in aggs %}
            {% for distinct_val in distinct_vals %}
                ,{{ agg }}({{ cleanse_name(distinct_val) }}_{{ col }}) AS {{ cleanse_name(distinct_val) }}_{{ agg }}_{{ col }}
            {%- endfor %}
        {%- endfor %}
    {%- endfor %}
    FROM TEMP
    GROUP BY {{ x_axis }}
    {{ ("ORDER BY " + x_axis + " " + x_axis_order) if x_axis_order else '' }}
{%- else %}
    SELECT
    {{ x_axis }},

    {%- for col, aggs in metrics.items() %}
        {%- set outer_loop = loop -%}
        {%- for agg in aggs %}
            {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
        {%- endfor -%}
    {%- endfor %}
    FROM {{ source_table }}
    {%- if filters is defined and filters %}
        {% for filter_block in filters %}
        {%- set oloop = loop -%}
        {{ 'WHERE ' if oloop.first else ' AND ' }}
            {%- if filter_block is not mapping -%}
                {{ filter_block }}
            {%- else -%}
                {%- if filter_block['operator'] == 'CONTAINS' -%}
                    {{ filter_block['operator'] }}({{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }})
                {%- else -%}
                    {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
                {%- endif -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endif %}
    GROUP BY {{ x_axis }}
    {{ ("ORDER BY " + x_axis + " " + x_axis_order) if x_axis_order else '' }}
{% endif %}

{%- endif %}
