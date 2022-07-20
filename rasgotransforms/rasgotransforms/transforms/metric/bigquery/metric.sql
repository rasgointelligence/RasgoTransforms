{%- set start_date = '2010-01-01' if not start_date else start_date -%}
{%- set end_date = '2030-01-01' if not end_date else end_date -%}
{%- set num_days = 7300 if not num_days else num_days -%}
{%- set alias = 'metric_value' if not alias else alias -%}
{%- set distinct = true if 'distinct' in aggregation_type|lower else false -%}
{%- set aggregation_type = aggregation_type|upper|replace('_', '')|replace('DISTINCT', '')|replace('MEAN', 'AVG') -%}

{# {%- set num_days = (end_date|string|todatetime - start_date|string|todatetime).days + 1 -%} #}
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

with source_query as (
    select
        cast(date_trunc(cast({{ time_dimension }} as date), day) as date) as date_day,
        {%- for dimension in dimensions %}
        {{ dimension }},
        {%- endfor %}
        {{ target_expression }} as property_to_aggregate
    from {{ source_table }}
    {{ filter_statement }}
),
{%- if time_grain|lower == 'all'%}
spine as (
    select
        cast('{{ start_date }}' as date) as {{ time_dimension }}_min,
        cast('{{ end_date }}' as date) as {{ time_dimension }}_max
),
joined as (
    select *
    from source_query
        cross join spine
),
tidy_data as (
    select
        {{ time_dimension }}_min,
        {{ time_dimension }}_max,
        {%- for dimension in dimensions %}
        {{ dimension }},
        {%- endfor %}
        {{ aggregation_type }}({{ 'distinct ' if distinct else ''}}joined.property_to_aggregate) as {{ alias }},
    from joined
    group by {{ range(1, dimensions|length + 3)|join(', ') }}
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
        logical_or(source_query.date_day is not null) as has_data
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
        cast(period as timestamp) as {{ time_dimension }}_min,
        {%- if time_grain|lower == 'quarter' %}
        cast(date_add(period, INTERVAL 3 month) as timestamp) as {{ time_dimension }}_max,
        {%- else %}
        cast(date_add(period, INTERVAL 1 {{ time_grain }}) as timestamp) as {{ time_dimension }}_max,
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
{%- endif %}
select * from tidy_data