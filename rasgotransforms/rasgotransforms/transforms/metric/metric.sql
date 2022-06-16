{%- set start_date = '2010-01-01' if not start_date else start_date -%}
{%- set num_days = 7300 if not num_days else num_days -%}
{%- set alias = 'metric_value' if not alias else alias -%}
{%- set distinct = true if 'distinct' in aggregation_type|lower else false -%}
{%- set aggregation_type = aggregation_type|upper|replace('_', '')|replace('DISTINCT', '')|replace('MEAN', 'AVG') -%}

with source_query as (
    select
        cast(date_trunc('day', cast({{ time_dimension }} as date)) as date) as date_day,
        {%- for dimension in dimensions %}
        {{ dimension }},
        {%- endfor %}
        {{ target_expression }} as property_to_aggregate

    from {{ source_table }}
    where {{ time_dimension }} >= '{{ start_date }}'
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
final as (
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
select * from final