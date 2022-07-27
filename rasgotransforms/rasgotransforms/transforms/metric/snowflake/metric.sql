{%- set start_date = '2010-01-01' if not start_date else start_date|string -%}
{%- set end_date = '2030-01-01' if not end_date else end_date|string -%}
{%- set num_days = 7300 if not num_days else num_days -%}
{%- set alias = 'metric_value' if not alias else alias -%}
{%- set distinct = true if 'distinct' in aggregation_type|lower else false -%}
{%- set aggregation_type = aggregation_type|upper|replace('_', '')|replace('DISTINCT', '')|replace('MEAN', 'AVG') -%}
{%- set flatten = flatten if flatten is defined else true -%}
{%- set max_num_groups = max_num_groups if max_num_groups is defined else 10 -%}
{%- set filters = filters if filters is defined else [] -%}
{%- do filters.append({'columnName': time_dimension, 'operator': '>=', 'comparisonValue': "'" + start_date + "'" }) -%}
{%- do filters.append({'columnName': time_dimension, 'operator': '<=', 'comparisonValue': "'" + end_date + "'" }) -%}

{%- set filter_statement -%}
    where true
        {%- for filter in filters %}
        {%- if filter is not mapping %}
        and {{ filter }}
        {%- elif filter.operator|upper == 'CONTAINS' %}
        and {{ filter.operator }}({{ filter.columnName }}, {{ filter.comparisonValue }})
        {%- else %}
        and {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
        {%- endif %}
        {%- endfor %}
{%- endset -%}

{%- macro get_distinct_values(columns) -%}
    {%- set distinct_val_query %}
        select
            {%- for column in columns %}
            to_char({{ column }}) as {{ column }},
            {%- endfor %}
            {{ aggregation_type }}({{ 'distinct ' if distinct else ''}}{{ target_expression}}) as vals
        from {{ source_table }} 
        {{ filter_statement }}
        group by {{ range(1, dimensions|length + 1)|join(', ') }}
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

{%- if dimensions -%}
{%- set distinct_values = get_distinct_values(dimensions).split('|$|') -%}
{%- if distinct_values|length > max_num_groups %}
{%- set distinct_values = distinct_values[:-1] + ['_OtherGroup'] -%}
{%- endif -%}
{%- endif -%}

with source_query as (
    select
        cast(date_trunc('day', cast({{ time_dimension }} as date)) as date) as date_day,
        {%- for dimension in dimensions %}
        case
            when to_char({{ dimension }}) in (
                {%- for val in distinct_values %}
                '{{ val }}'{{',' if not loop.last else ''}}
                {%- endfor %}
            ) then to_char({{ dimension }})
            {%- if 'None' in distinct_values %}
            when {{ dimension }} is null then 'None'
            {%- endif %}
            else '_OtherGroup'
        end as {{ dimension }},
        {%- endfor %}
        {{ target_expression }} as property_to_aggregate
    from {{ source_table }}
    {{ filter_statement }}
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
spine__time as (
        select
        date_{{ time_grain }} as period,
        date_day
        from calendar
),
{%- for dimension in dimensions %}
spine__values__{{ dimension }} as (
    select distinct {{ dimension }}
    from source_query
),
{%- endfor %}
spine as (
    select *
    from spine__time
        {%- for dimension in dimensions %}
        cross join spine__values__{{ dimension }}
        {%- endfor %}
),
joined as (
    select
        spine.period,
        {%- for dimension in dimensions %}
        spine.{{ dimension }},
        {%- endfor %}
        {{ aggregation_type }}({{ 'distinct ' if distinct else ''}}source_query.property_to_aggregate) as {{ alias }},
        boolor_agg(source_query.date_day is not null) as has_data
    from spine
    left outer join source_query on source_query.date_day = spine.date_day
        {%- for dimension in dimensions %}
        and (source_query.{{ dimension }} = spine.{{ dimension }}
            or source_query.{{ dimension }} is null and spine.{{ dimension }} is null)
        {%- endfor %}
    group by {{ range(1, dimensions|length + 2)|join(', ') }}
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
        cast(period as timestamp) as period_min,
        {%- if time_grain|lower == 'quarter' %}
        dateadd('second', -1, dateadd('month',3, period_min)) as period_max,
        {%- else %}
        dateadd('second', -1, dateadd('{{ time_grain }}',1, period_min)) as period_max,
        {%- endif %}
        {%- for dimension in dimensions %}
        {{ dimension }},
        {%- endfor %}
        coalesce({{ alias }}, 0) as {{ alias }}
    from bounded
    where period >= lower_bound
    and period <= upper_bound
    order by {{ range(1, dimensions|length + 2)|join(', ') }}
)
{%- if not dimensions or not flatten %}
select * from tidy_data order by period_min
{%- else -%}
, 
combined_dimensions as (
    select
        concat( 
        {%- for dimension in dimensions -%} 
            {{ dimension }}{{ ",'_'," if not loop.last else ''}}
        {%- endfor -%}) as dimensions,
        period_min,
        period_max,
        {{ alias }}
    from tidy_data
),
pivoted as (
    select
        period_min,
        period_max,
        {% for val in distinct_values -%}
        {{ cleanse_name(val) }}{{',' if not loop.last else ''}}
        {%- endfor %}
    from (
        select 
            period_min,
            period_max,
            {{ alias }},
            dimensions
        from combined_dimensions
    )
    pivot (
        sum({{ alias }}) for dimensions in (
            {% for val in distinct_values -%}
            '{{ val }}'{{',' if not loop.last else ''}}
            {%- endfor %}
        )
    ) as p (
        period_min,
        period_max,
        {% for val in distinct_values -%}
        {{ cleanse_name(val) }}{{',' if not loop.last else ''}}
        {%- endfor %}
    )
)
select * from pivoted order by period_min
{%- endif -%}
