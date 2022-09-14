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
{% set filter_statement = get_filter_statement(filters) %}
{% set aggregation_columns = []|to_set %}
{% for aggregation in aggregations %}
{% do aggregation_columns.add(aggregation.column) %}
{% endfor %}
with
    {% if distinct_values and dimensions %}
    combined_dimensions as (
        select
            {{ time_dimension }},
            {% for column in aggregation_columns %}
            {{ column }},
            {% endfor %}
            concat(''{{',' if dimensions}}
                {% for column in dimensions %}
                {{ column }}{{", '_', " if not loop.last}}
                {% endfor %}
            ) as dimensions
        from {{ source_table }}
    ),
    {% endif %}
    source_query as (
        select
            cast(
                date_trunc(cast({{ time_dimension }} as date), day) as date
            ) as date_day,
            {% if distinct_values and dimensions %}
            case
                when dimensions in (
                        {%- for val in distinct_values %}
                        '{{ val }}'{{',' if not loop.last else ''}}
                        {%- endfor %}
                    ) then dimensions
                {% if 'None' in distinct_values %}
                when dimensions is null then 'None'
                {% endif %}
                else '_OtherGroup'
            end as dimensions,
            {% else %}
            {% for dimension in dimensions %}
            {{ dimension }},
            {% endfor %}
            {% endif %}
            {% for column in aggregation_columns %}
            {{ column }}{{ ',' if not loop.last }}
            {% endfor %}
        from {{ source_table if not (distinct_values and dimensions) else 'combined_dimensions'}}
        where ({{ time_dimension }} >= '{{ start_date }}' and {{ time_dimension }} <= '{{ end_date }}') and
            {{ filter_statement | indent(12) }}
    ),
    {% if distinct_values and dimensions %}
    {% set dimensions=['dimensions'] %}
    {% endif %}
    {% if time_grain|lower == 'all' %}
    spine as (
        select
            cast('{{ start_date }}' as timestamp) as period_min,
            cast('{{ end_date }}' as timestamp) as period_max
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
            {% if time_grain|lower == 'quarter' %}
            cast(
                date_add(period, interval 3 month) as timestamp
            ) as period_max,
            {% else %}
            cast(
                date_add(period, interval 1 {{ time_grain }}) as timestamp
            ) as period_max,
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
with
{% if distinct_values and dimensions %}
combined_dimensions as (
    select
        {{ x_axis }},
        {% for column in aggregation_columns %}
        {{ column }},
        {% endfor %}
        concat(''{{',' if dimensions}}
            {%- for column in dimensions %}
            {{ column }}{{", '_', " if not loop.last}}
            {%- endfor %}
        ) as dimensions
    from {{ source_table }}
),
{% endif %}
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
        {% if distinct_values %}
        dimensions,
        {% else %}
        {% for column in dimensions %}
        {{ column }},
        {% endfor %}
        {% endif %}
        min_val,
        max_val,
        bucket_size,
        cast({{ x_axis }} as decimal) as col_a_val,
        range_bucket(cast({{ x_axis }} as numeric), generate_array(min_val, max_val, (max_val - min_val)/{{ bucket_count }})) as bucket,
        {% for column in aggregation_columns %}
        {{ column }}{{ ',' if not loop.last }}
        {% endfor %}
    from
        {{ source_table if not (distinct_values and dimensions) else 'combined_dimensions'}}
        cross join edges
    where
        {{ filter_statement | indent(8) }}
),
source_query as (
    select
        bucket,
        {% if distinct_values and dimensions %}
        case
            when dimensions in (
                    {%- for val in distinct_values %}
                    '{{ val }}'{{',' if not loop.last else ''}}
                    {%- endfor %}
                ) then dimensions
            {% if 'None' in distinct_values %}
            when dimensions is null then 'None'
            {% endif %}
            else '_OtherGroup'
        end as dimensions,
        {% else %}
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
    select bucket
    from unnest(generate_array(1, {{ bucket_count }})) as bucket
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
    select bucket
    from unnest(generate_array(1, {{ bucket_count }})) as bucket
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
        logical_or(source_query.bucket is not null) as has_data
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
with
{% if distinct_values and dimensions %}
combined_dimensions as (
    select
        {{ x_axis }},
        {% for column in aggregation_columns %}
        {{ column }},
        {% endfor %}
        concat(''{{',' if dimensions}}
            {%- for column in dimensions %}
            {{ column }}{{", '_', " if not loop.last}}
            {%- endfor %}
        ) as dimensions
    from {{ source_table }}
),
{% endif %}
source_query as (
    select
        {{ x_axis }},
        {% if distinct_values and dimensions %}
        case
            when dimensions in (
                    {%- for val in distinct_values %}
                    '{{ val }}'{{',' if not loop.last else ''}}
                    {%- endfor %}
                ) then dimensions
            {% if 'None' in distinct_values %}
            when dimensions is null then 'None'
            {% endif %}
            else '_OtherGroup'
        end as dimensions,
        {% else %}
        {% for dimension in dimensions %}
        {{ dimension }},
        {% endfor %}
        {% endif %}
        {% for column in aggregation_columns %}
        {{ column }}{{ ',' if not loop.last }}
        {% endfor %}
    from {{ source_table if not (distinct_values and dimensions) else 'combined_dimensions'}}
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
