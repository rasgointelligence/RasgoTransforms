{% from 'filter.sql' import get_filter_statement %}

{% macro calculate_timeseries_metric_values(
    metrics,
    time_dimension,
    dimensions,
    start_date,
    end_date,
    time_grain,
    source_table,
    filters,
    distinct_vals
) %}
{% set num_days = (end_date | todatetime - start_date | todatetime).days %}
{% set filter_statement = get_filter_statement(filters) %}
with combined_dimensions as (
    select *,
        concat(''{{',' if dimensions}}
            {% for column in dimensions %}
            {{ column }}{{", '_', " if not loop.last}}
            {% endfor %}
        ) as dimensions
    from {{ source_table }}
),
source_query as (
    select
        cast(date_trunc(cast({{ time_dimension }} as date), day) as date) as date_day,
        {% if dimensions %}
        case
            when dimensions in (
                    {% for val in distinct_vals %}
                    '{{ val }}'{{',' if not loop.last else ''}}
                    {% endfor %}
                ) then dimensions
            {% if 'None' in distinct_vals %}
            when dimensions is null then 'None'
            {% endif %}
            else '_OtherGroup'
        end as dimensions,
        {% endif %}
        {% for metric in metrics %}
        {{ metric.column }}{{ ',' if not loop.last }}
        {% endfor %}
    from combined_dimensions
    {{ filter_statement }}
),
{% if time_grain|lower == 'all'%}
spine as (
    select
        cast('{{ start_date }}' as timestamp) as {{ time_dimension }}_min,
        cast('{{ end_date }}' as timestamp) as {{ time_dimension }}_max
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
        {{ 'dimensions,' if dimensions }}
        {% for metric in metrics %}
        {{ metric.agg_method|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in metric.agg_method|lower else ''}}{{ metric.column }}) as {{ metric.alias }}{{ ',' if not loop.last }}
        {% endfor %}
    from joined
    group by 1, 2{{ ', 3' if dimensions}}
)
{% else %}
calendar as (
  select
    date_day,
    date_trunc(date_day, week) as date_week,
    date_trunc(date_day, month) as date_month,
    date_trunc(date_day, quarter) as date_quarter,
    date_trunc(date_day, year) as date_year
    from unnest(generate_date_array('{{ start_date }}', '{{ end_date }}')) as date_day
),
{% if dimensions %}
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
{% else %}
spine as (
        select
        date_{{ time_grain }} as period,
        date_day
        from calendar
),
{% endif %}
joined as (
    select
        spine.period,
        {{ 'spine.dimensions,' if dimensions }}
        {% for metric in metrics %}
        {{ metric.agg_method|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in metric.agg_method|lower else ''}} source_query.{{ metric.column }}) as {{ metric.alias }},
        {% endfor %}
        logical_or(source_query.date_day is not null) as has_data
    from spine
    left outer join source_query on source_query.date_day = spine.date_day
        {% if dimensions %}
        and (source_query.dimensions = spine.dimensions
            or source_query.dimensions is null and spine.dimensions is null)
        {% endif %}
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
        {% if time_grain|lower == 'quarter' %}
        cast(date_add(period, INTERVAL 3 month) as timestamp) as {{ time_dimension }}_max,
        {% else %}
        cast(date_add(period, INTERVAL 1 {{ time_grain }}) as timestamp) as {{ time_dimension }}_max,
        {% endif %}
        {{ 'dimensions,' if dimensions }}
        {% for metric in metrics %}
        {{ metric.alias }}{{ ',' if not loop.last }}
        {% endfor %}
    from bounded
    where period >= lower_bound
    and period <= upper_bound
    order by 1, 2{{ ', 3' if dimensions }}
)
{% endif %}
select *
from tidy_data
{% endmacro %}
