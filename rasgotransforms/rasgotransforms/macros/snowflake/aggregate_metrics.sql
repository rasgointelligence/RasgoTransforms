{% from 'filter.sql' import get_filter_statement %}

{% macro calculate_timeseries_metric_values(
    aggregations,
    time_dimension,
    dimensions,
    start_date,
    end_date,
    time_grain,
    source_table,
    filters,
    distinct_values
) %}
{% set num_days = (end_date | todatetime - start_date | todatetime).days %}
{% set filter_statement = get_filter_statement(filters) %}
{% set aggregation_columns = []|to_set %}
{% for aggregation in aggregations %}
{% do aggregation_columns.add(aggregation.column) %}
{% endfor %}
with
    source_query as (
        select
            cast(
                date_trunc('day', cast({{ time_dimension }} as date)) as date
            ) as date_day,
            {% if distinct_values and dimensions %}
            concat(
                {% for dimension in dimensions %}
                {{ dimension }}{{", '_', " if not loop.last}}
                {% endfor %}
            ) as combined_dimensions,
            case
                when combined_dimensions in (
                    {% for val in distinct_values %}
                    '{{ val }}'{{',' if not loop.last else ''}}
                    {% endfor %}
                ) then combined_dimensions
                {% if 'None' in distinct_values %}
                when combined_dimensions is null then 'None'
                {% endif %}
                else '_OtherGroup'
            end as dimensions,
            {%  else %}
            {% for dimension in dimensions %}
            {{ dimension }},
            {% endfor %}
            {% endif %}
            {% for column in aggregation_columns %}
            {{ column }}{{ ',' if not loop.last }}
            {% endfor %}
        from {{ source_table }}
        where ({{ time_dimension }} >= '{{ start_date }}' and {{ time_dimension }} <= '{{ end_date }}') and
            {{ filter_statement | indent(12) }}
    ),
    {% if distinct_values and dimensions %}
    {% set dimensions = ['dimensions'] %}
    {% endif %}
    {% if time_grain | lower == "all" %}
    spine as (
        select
            cast('{{ start_date }}' as timestamp_ntz) as period_min,
            cast('{{ end_date }}' as timestamp_ntz) as period_max
    ),
    joined as (select * from source_query cross join spine),
    tidy_data as (
        select
            period_min,
            period_max,
            {% for dimension in dimensions %}
            {{ dimension }},
            {% endfor %}
            {% for aggregation in aggregations %}
            {{ aggregation.method | lower | replace("_", "") | replace("distinct", "") }} (
                {{ "distinct " if "distinct" in aggregation.method | lower else "" }}{{ aggregation.column }}
            ) as {{ aggregation.alias }}{{ ',' if not loop.last }}
            {% endfor %}
        from joined
        group by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n' }}{% endfor %}
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
            ) as {{ aggregation.alias }}{{ ',' if not loop.last }}
            {% endfor %}
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
    tidy_data as (
        select
            cast(period as timestamp) as period_min,
            {% if time_grain | lower == "quarter" %}
            dateadd('month', 3, period_min) as period_max,
            {% else %}
            dateadd('{{ time_grain }}', 1, period_min) as period_max,
            {% endif %}
            {% for dimension in dimensions %}
            {{ dimension }},
            {% endfor %}
            {% for aggregation in aggregations %}
            {{ aggregation.alias }}{{ ',' if not loop.last }}
            {% endfor %}
        from joined
        order by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n'}}{% endfor %}
    )
    {% endif %}
    select * from tidy_data
{% endmacro %}

{% macro calculate_continuous_metric_values(
    aggregations,
    x_axis,
    dimensions,
    source_table,
    bucket_count,
    filters,
    distinct_values
) %}
{% set filter_statement = get_filter_statement(filters) %}
{% set aggregation_columns = []|to_set %}
{% for aggregation in aggregations %}
{% do aggregation_columns.add(aggregation.column) %}
{% endfor %}
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
        {% for column in dimensions %}
        {{ column }},
        {% endfor %}
        min_val,
        max_val,
        bucket_size,
        cast({{ x_axis }} as float) as col_a_val,
        width_bucket(col_a_val, min_val, max_val, {{ bucket_count }}) as bucket,
        {% for column in aggregation_columns %}
        {{ column }}{{ ',' if not loop.last }}
        {% endfor %}
    from
        {{ source_table }}
        cross join edges
    where
        {{ filter_statement | indent(8) }}
),
source_query as (
    select
        bucket,
        {% if distinct_values and dimensions %}
        concat(
            {% for dimension in dimensions %}
            {{ dimension }}{{", '_', " if not loop.last}}
            {% endfor %}
        ) as combined_dimensions,
        case
            when combined_dimensions in (
                {% for val in distinct_values %}
                '{{ val }}'{{',' if not loop.last else ''}}
                {% endfor %}
            ) then combined_dimensions
            {% if 'None' in distinct_values %}
            when combined_dimensions is null then 'None'
            {% endif %}
            else '_OtherGroup'
        end as dimensions,
        {%  else %}
        {% for dimension in dimensions %}
        {{ dimension }},
        {% endfor %}
        {% endif %}
        {% for column in aggregation_columns %}
        {{ column }}{{ ',' if not loop.last }}
        {% endfor %}
    from buckets
),
{% if distinct_values and dimensions %}
{% set dimensions = ['dimensions'] %}
{% endif %}
{% if dimensions %}
bucket_spine as (
    select
        row_number() over (order by null) as bucket
    from table (generator(rowcount => {{ bucket_count }}))
),
{% for dimension in dimensions %}
spine__values__{{ dimension }} as (
    select distinct {{ dimension }} from source_query
),
{% endfor %}
spine as (
    select * from bucket_spine
        {% for dimension in dimensions %}
        cross join spine__values__{{ dimension }}
        {% endfor %}
),
{% else %}
spine as (
    select
        row_number() over (order by null) as bucket
    from table (generator(rowcount => {{ bucket_count }}))
),
{% endif %}
joined as (
    select
        spine.bucket,
        {% for dimension in dimensions %}
        spine.{{ dimension }},
        {% endfor %}
        {% for aggregation in aggregations %}
        {{ aggregation.method | lower | replace("_", "") | replace("distinct", "") }} (
            {{ "distinct " if "distinct" in aggregation.method | lower else "" }} source_query.{{ aggregation.column }}
        ) as {{ aggregation.alias }},
        {% endfor %}
        boolor_agg(source_query.bucket is not null) as has_data
    from spine
    left outer join
        source_query on source_query.bucket = spine.bucket
        {% for dimension in dimensions %}
        and (
            source_query.{{ dimension }} = spine.{{ dimension }}
            or source_query.{{ dimension }} is null
            and spine.{{ dimension }} is null
        )
        {% endfor %}
    group by {% for i in range(1, 2 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n'}}{% endfor %}
),
tidy_data as (
    select
        min_val+((bucket-1)*bucket_size) as {{ x_axis }}_min,
        min_val+(bucket*bucket_size) as {{ x_axis }}_max,
        {% for dimension in dimensions %}
        {{ dimension }},
        {% endfor %}
        {% for aggregation in aggregations %}
        {{ aggregation.alias }}{{ ',' if not loop.last }}
        {% endfor %}
    from joined
        cross join edges
    order by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n'}}{% endfor %}
)
select * from tidy_data
{% endmacro %}

{% macro calculate_categorical_metric_values(
    aggregations,
    x_axis,
    dimensions,
    source_table,
    filters,
    distinct_values
) %}
{% set filter_statement = get_filter_statement(filters) %}
{% set aggregation_columns = []|to_set %}
{% for aggregation in aggregations %}
{% do aggregation_columns.add(aggregation.column) %}
{% endfor %}
with source_query as (
    select
        {{ x_axis }},
        {% if distinct_values and dimensions %}
        concat(
            {% for dimension in dimensions %}
            {{ dimension }}{{", '_', " if not loop.last}}
            {% endfor %}
        ) as combined_dimensions,
        case
            when combined_dimensions in (
                {% for val in distinct_values %}
                '{{ val }}'{{',' if not loop.last else ''}}
                {% endfor %}
            ) then combined_dimensions
            {% if 'None' in distinct_values %}
            when combined_dimensions is null then 'None'
            {% endif %}
            else '_OtherGroup'
        end as dimensions,
        {%  else %}
        {% for dimension in dimensions %}
        {{ dimension }},
        {% endfor %}
        {% endif %}
        {% for column in aggregation_columns %}
        {{ column }}{{ ',' if not loop.last }}
        {% endfor %}
    from {{ source_table }}
    where
        {{ filter_statement | indent(8) }}
),
{% if distinct_values and dimensions %}
{% set dimensions = ['dimensions'] %}
{% endif %}
tidy_data as (
    select
        {{ x_axis }} as {{ x_axis }}_min,
        {{ x_axis }} as {{ x_axis }}_max,
        {% for dimension in dimensions %}
        {{ dimension }},
        {% endfor %}
        {% for aggregation in aggregations %}
        {{ aggregation.method | lower | replace("_", "") | replace("distinct", "") }} (
            {{ "distinct " if "distinct" in aggregation.method | lower else "" }} source_query.{{ aggregation.column }}
        ) as {{ aggregation.alias }}{{ ',' if not loop.last }}
        {% endfor %}
    from source_query
    group by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n' }}{% endfor %}
)
select * from tidy_data
order by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n' }}{% endfor %}
{% endmacro %}
