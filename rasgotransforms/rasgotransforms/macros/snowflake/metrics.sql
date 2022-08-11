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
with
    source_query as (
        select
            cast(
                date_trunc('day', cast({{ time_dimension }} as date)) as date
            ) as date_day,
            {% if dimensions %}
            concat(
                {% for column in dimensions %}
                {{ column }}{{ ", '_', " if not loop.last }}
                {% endfor %}
            ) as combined_dimensions,
            case
                when
                    combined_dimensions in (
                        {% for val in distinct_vals %}
                        '{{ val }}'{{ "," if not loop.last else "" }}
                        {% endfor %}
                    )
                then combined_dimensions
                {% if "None" in distinct_vals %}
                when combined_dimensions is null then 'None'
                {% endif %}
                else '_OtherGroup'
            end as dimensions,
            {% endif %}
            {% for metric in metrics %}
            {{ metric.column }}{{ ',' if not loop.last }}
            {% endfor %}
        from {{ source_table }} {{ filter_statement | indent }}
    ),
    {% if time_grain | lower == "all" %}
    spine as (
        select
            cast('{{ start_date }}' as timestamp_ntz) as {{ time_dimension }}_min,
            cast('{{ end_date }}' as timestamp_ntz) as {{ time_dimension }}_max
    ),
    joined as (select * from source_query cross join spine),
    tidy_data as (
        select
            {{ time_dimension }}_min,
            {{ time_dimension }}_max,
            {{ 'dimensions,' if dimensions }}
            {% for metric in metrics %}
            {{ metric.agg_method | lower | replace("_", "") | replace("distinct", "") }} (
                {{ "distinct " if "distinct" in metric.agg_method | lower else "" }}{{ metric.column }}
            ){{ ',' if not loop.last }}
            {% endfor %}
        from joined
        group by 1, 2{{ ', 3' if dimensions }}
    )
    {% else %}
    calendar as (
        select
            row_number() over (order by null) as interval_id,
            cast(
                dateadd(
                    'day', interval_id -1, '{{ start_date }}'::timestamp_ntz
                ) as date
            ) as date_day,
            cast(date_trunc('week', date_day) as date) as date_week,
            cast(date_trunc('month', date_day) as date) as date_month,
            case
                when month(date_day) in (1, 2, 3)
                then date_from_parts(year(date_day), 1, 1)
                when month(date_day) in (4, 5, 6)
                then date_from_parts(year(date_day), 4, 1)
                when month(date_day) in (7, 8, 9)
                then date_from_parts(year(date_day), 7, 1)
                when month(date_day) in (10, 11, 12)
                then date_from_parts(year(date_day), 10, 1)
            end as date_quarter,
            cast(date_trunc('year', date_day) as date) as date_year
        from table(generator(rowcount => {{ num_days }}))
    ),
    {% if dimensions %}
    spine__time as (select date_{{ time_grain }} as period, date_day from calendar),
    spine__values__dimensions as (select distinct dimensions from source_query),
    spine as (select * from spine__time cross join spine__values__dimensions),
    {% else %}
    spine as (select date_{{ time_grain }} as period, date_day from calendar),
    {% endif %}
    joined as (
        select
            spine.period,
            {{ 'spine.dimensions,' if dimensions }}
            {% for metric in metrics %}
            {{ metric.agg_method | lower | replace("_", "") | replace("distinct", "") }} (
                {{ "distinct " if "distinct" in metric.agg_method | lower else "" }} source_query.{{ metric.column }}
            ) as {{ metric.alias }},
            {% endfor %}
            boolor_agg(source_query.date_day is not null) as has_data
        from spine
        left outer join
            source_query on source_query.date_day = spine.date_day
            {% if dimensions %}
            and (
                source_query.dimensions = spine.dimensions
                or source_query.dimensions is null
                and spine.dimensions is null
            )
            {% endif %}
        group by 1{{ ', 2' if dimensions }}
    ),
    bounded as (
        select
            *,
            min(case when has_data then period end) over () as lower_bound,
            max(case when has_data then period end) over () as upper_bound
        from joined
    ),
    tidy_data as (
        select
            cast(period as timestamp) as {{ time_dimension }}_min,
            {% if time_grain | lower == "quarter" %}
            dateadd(
                'second', -1, dateadd('month', 3, {{ time_dimension }}_min)
            ) as {{ time_dimension }}_max,
            {% else %}
            dateadd(
                'second', -1, dateadd('{{ time_grain }}', 1, {{ time_dimension }}_min)
            ) as {{ time_dimension }}_max,
            {% endif %}
            {{ 'dimensions,' if dimensions }}
            {% for metric in metrics %}
            {{ metric.alias }}{{ ',' if not loop.last }}
            {% endfor %}
        from bounded
        where period >= lower_bound and period <= upper_bound
        order by 1, 2{{ ', 3' if dimensions }}
    )
{% endif %}
select *
from tidy_data
{% endmacro %}
