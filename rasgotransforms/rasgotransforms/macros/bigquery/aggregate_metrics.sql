{% from 'filter.sql' import get_filter_statement %}

{% macro calculate_timeseries_metric_values(
    aggregations,
    time_dimension,
    dimensions,
    start_date,
    end_date,
    time_grain,
    source_table,
    filters
) %}
{% set filter_statement = get_filter_statement(filters) %}
with
    source_query as (
        select
            cast(
                date_trunc(cast({{ time_dimension }} as date), day) as date
            ) as date_day,
            {% for dimension in dimensions %}
            {{ dimension }},
            {% endfor %}
            {% for aggregation in aggregations %}
            {{ aggregation.column }}{{ ',' if not loop.last }}
            {% endfor %}
        from {{ source_table }} {{ filter_statement | indent }}
    ),
    {% if time_grain|lower == 'all' %}
    spine as (
        select
            cast('{{ start_date }}' as timestamp) as {{ time_dimension }}_min,
            cast('{{ end_date }}' as timestamp) as {{ time_dimension }}_max
    ),
    joined as (select * from source_query cross join spine),
    tidy_data as (
        select
            {{ time_dimension }}_min,
            {{ time_dimension }}_max,
            {% for dimension in dimensions %}
            {{ dimension }},
            {% endfor %}
            {% for aggregation in aggregations %}
            {{ aggregation.method|lower|replace('_', '')|replace('distinct', '') }} (
                {{ 'distinct ' if 'distinct' in aggregation.method|lower else '' }}{{ aggregation.column }}
            ) as {{ aggregation.alias }}{{ ',' if not loop.last }}
            {% endfor %}
        from joined
        group by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n' }}{% endfor %}
    )
    {% else %}
    calendar as (
        select
            date_day,
            date_trunc(date_day, week) as date_week,
            date_trunc(date_day, month) as date_month,
            date_trunc(date_day, quarter) as date_quarter,
            date_trunc(date_day, year) as date_year
        from
            unnest(
                generate_date_array('{{ start_date }}', '{{ end_date }}')
            ) as date_day
    ),
    {% if dimensions %}
    spine__time as (select date_{{ time_grain }} as period, date_day from calendar),
    {% for dimension in dimensions %}
    spine__values__{{ dimension }} as (select distinct {{ dimension }} from source_query),
    {% endfor %}
    spine as (
        select *
        from spine__time
            {% for dimension in dimensions %}
            cross join spine__values__{{ dimension }}
            {% endfor %}
    ),
    {% else %}
    spine as (select date_{{ time_grain }} as period, date_day from calendar),
    {% endif %}
    joined as (
        select
            spine.period,
            {% for dimension in dimensions %}
            spine.{{ dimension }},
            {% endfor %}
            {% for aggregation in aggregations %}
            {{ aggregation.method | lower | replace("_", "") | replace("distinct", "") }} (
                {{ "distinct " if "distinct" in aggregation.method | lower else "" }} source_query.{{ aggregation.column }}
            ) as {{ aggregation.alias }},
            {% endfor %}
            logical_or(source_query.date_day is not null) as has_data
        from spine
        left outer join
            source_query on source_query.date_day = spine.date_day
            {% for dimension in dimensions %}
            and (
                source_query.{{ dimension }} = spine.{{ dimension }}
                or source_query.{{ dimension }} is null
                and spine.{{ dimension }} is null
            )
            {% endfor %}
        group by {% for i in range(1, 2 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n'}}{% endfor %}
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
            {% if time_grain|lower == 'quarter' %}
            cast(
                date_add(period, interval 3 month) as timestamp
            ) as {{ time_dimension }}_max,
            {% else %}
            cast(
                date_add(period, interval 1 {{ time_grain }}) as timestamp
            ) as {{ time_dimension }}_max,
            {% endif %}
            {{ 'dimensions,' if dimensions }}
            {% for aggregation in aggregations %} {{ aggregation.alias }}{{ ',' if not loop.last }}
            {% endfor %}
        from bounded
        where period >= lower_bound and period <= upper_bound
        order by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n'}}{% endfor %}
    )
    {% endif %}
    select * from tidy_data
{% endmacro %}
