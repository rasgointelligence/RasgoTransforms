{% from 'aggregate_metrics.sql' import calculate_timeseries_metric_values, calculate_continuous_metric_values, calculate_categorical_metric_values %}
{% from 'expression_metrics.sql' import calculate_expression_metric_values %}
{% from 'distinct_values.sql' import get_distinct_vals %}
{% from 'pivot.sql' import pivot_plot_values %}
{% from 'filter.sql' import get_filter_statement, combine_filters %}
{% set dimensions = group_by if group_by is defined else [] %}
{% set flatten = flatten if flatten is defined else true %}
{% set max_num_groups = max_num_groups if max_num_groups is defined else 10 %}
{% set bucket_count = num_buckets if num_buckets is defined else 200 %}
{% set filters = filters if filters is defined else [] %}
{% set axis_type_dict = get_columns(source_table) %}
{% set axis_type_response = axis_type_dict[x_axis.upper()].upper() %}
{% set group_by = [group_by] if group_by is defined and group_by is string else group_by%}
{% if 'DATE' in axis_type_response or 'TIME' in axis_type_response %}
  {% set axis_type = "date" %}
{% elif 'NUM' in axis_type_response or 'FLOAT' in axis_type_response or 'INT' in axis_type_response or 'DECIMAL' in axis_type_response or 'DOUBLE' in axis_type_response or 'REAL' in axis_type_response %}
    {% set axis_type = "numeric" %}
{% elif 'BINARY' in axis_type_response or 'TEXT' in axis_type_response or 'BOOLEAN' in axis_type_response or 'CHAR' in axis_type_response or 'STRING' in axis_type_response or 'VARBINARY' in axis_type_response %}
    {% set axis_type = "categorical" %}
{% else %}
    {{ raise_exception('The column selected as an axis is not categorical, numeric, or datetime. Please choose an axis that is any of these data types and recreate the transform.') }}
{% endif %}
{% if axis_type == 'date' %}
{% if timeseries_options %}
{% set start_date = '2010-01-01' if not timeseries_options.start_date else timeseries_options.start_date %}
{% set end_date = '2030-01-01' if not timeseries_options.end_date else timeseries_options.end_date %}
{% if not timeseries_options.end_date %}
{% set end_date = ((start_date|string|todatetime).now().date()|string) %}
{% else %}
{% set end_date = timeseries_options.end_date %}
{% endif %}
{% set time_grain = 'day' if not timeseries_options.time_grain else timeseries_options.time_grain %}
{% else %}
{{ raise_exception("Parameter 'timeseries_options' must be given when 'x_axis' is a column of type datetime")}}
{% endif %}
{% set num_days = (end_date|string|todatetime - start_date|string|todatetime).days + 1 %}
{% endif %}

{% set table_metrics = {} %}
{% set metric_names = [] %}
{% set aggregations = [] %}
{% for column, agg_methods in metrics.items() %}
{% for agg_method in agg_methods %}
{% set metric_name = cleanse_name(column + '_' + agg_method) %}
{% do aggregations.append({
    'column': column,
    'method': agg_method,
    'alias': metric_name
}) %}
{% do table_metrics.setdefault('aggregation_metrics', []).append(metric_name) %}
{% do metric_names.append(metric_name) %}
{% endfor %}
{% endfor %}

{% if dimensions %}
{% if start_date is defined %}
{% set date_filter %}
({{ x_axis }} >= '{{ start_date }}' AND {{ x_axis }} <= '{{ end_date }}')
{% endset %}
{% set distinct_vals_filters = get_filter_statement([
    date_filter,
    get_filter_statement(filters)
]) if start_date is defined else filters %}
{% else %}
{% set distinct_vals_filters = filters %}
{% endif %}

{% set distinct_values = get_distinct_vals(
    columns=dimensions,
    target_metric=metrics[0] if metrics else None,
    max_vals=max_num_groups,
    source_table=source_table,
    filters=distinct_vals_filters
) | from_json %}
{% if distinct_values is not defined or not distinct_values %}
    {{ raise_exception('This query returns 0 rows. Please adjust the inputs and try again.') }}
{% endif %}
{% endif %}

{% set base_query %}
{# Date Axis #}
{% if axis_type == 'date' %}
with
{# Expression Metrics #}
{% for metric in expression_metrics %}
{% do metric_names.append(metric.name) %}
{% if 'metricDependencies' in metric %}
{% do metric.__setitem__('metric_dependencies', metric.metricDependencies) %}
{% endif %}
{% if 'targetExpression' in metric %}
{% do metric.__setitem__('target_expression', metric.targetExpression) %}
{% endif %}
{% if 'timeDimension' in metric %}
{% do metric.__setitem__('time_dimension', metric.timeDimension) %}
{% endif %}
{% if 'sourceTable' in metric %}
{% do metric.__setitem__('source_table', metric.sourceTable) %}
{% endif %}
{% do table_metrics.__setitem__('metric__' + metric.name, [metric.name]) %}
metric__{{ metric.name }} as (
    {% if metric.type|lower == 'expression' %}
    {{ calculate_expression_metric_values(
        name=metric.name,
        metrics=metric.metric_dependencies,
        target_expression=metric.target_expression,
        dimensions=dimensions,
        start_date=start_date,
        end_date=end_date,
        time_grain=time_grain,
        distinct_values=distinct_values,
        filters=combine_filters(metric.filters, filters)
    ) | indent }}
    {% else %}
    {{ calculate_timeseries_metric_values(
        aggregations=[{
            'column': metric.target_expression,
            'method': metric.type,
            'alias': metric.name
        }],
        time_dimension=metric.time_dimension,
        dimensions=dimensions,
        start_date=start_date,
        end_date=end_date,
        time_grain=time_grain,
        source_table=metric.source_table,
        filters=combine_filters(metric.filters, filters),
        distinct_values=distinct_values
    ) | indent }}
    {% endif %}
),
{% endfor %}

{# Standard/Aggregation Metrics #}
{% if metrics|length > 0 %}
aggregation_metrics as (
    {{ calculate_timeseries_metric_values(
        aggregations=aggregations,
        time_dimension=x_axis,
        dimensions=dimensions,
        start_date=start_date,
        end_date=end_date,
        time_grain=time_grain,
        source_table=source_table,
        filters=filters,
        distinct_values=distinct_values
    ) | indent }}
),
{% endif %}

{# Join expression and aggregation metrics #}
{% set dimensions = ['dimensions'] if dimensions%}
{% set tables = table_metrics.keys()|list %}
joined as (
    select
        {{ tables[0] }}.period_min as {{ x_axis }}_min,
        {{ tables[0] }}.period_max as {{  x_axis }}_max,
        {% for dimension in dimensions %}
        {{ tables[0] }}.{{ dimension }},
        {% endfor %}
        {% for table, metric_names in table_metrics.items() %}
        {% set oloop = loop %}
        {% for metric_name in metric_names %}
        {{ table }}.{{ metric_name }}{{ ',' if not (loop.last and oloop.last) }}
        {% endfor %}
        {% endfor %}
    from {{ tables[0] }}
    {% for i in range(1, tables|length) %}
        left join {{ tables[i] }}
            on {{ tables[0] }}.period_min = {{ tables[i] }}.period_min
            {% for dimension in dimensions %}
            and {{ tables[0] }}.{{ dimension }} = {{ tables[i] }}.{{ dimension }}
            {% endfor %}
    {% endfor %}
)
select * from joined
order by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n' }}{% endfor %}

{# Numeric Axis #}
{% elif axis_type == 'numeric' %}
{{ calculate_continuous_metric_values(
    aggregations=aggregations,
    x_axis=x_axis,
    dimensions=dimensions,
    source_table=source_table,
    filters=filters,
    bucket_count=bucket_count,
    distinct_values=distinct_values
) }}

{# Categorical Axis #}
{% else %}
{{ calculate_categorical_metric_values(
    aggregations=aggregations,
    x_axis=x_axis,
    dimensions=dimensions,
    source_table=source_table,
    filters=filters,
    distinct_values=distinct_values
) }}
{% endif %}
{% endset %}

{% if dimensions %}
{{ pivot_plot_values(
    base_query=base_query,
    x_axis=x_axis,
    metric_names=metric_names,
    distinct_values=distinct_values,
    axis_type=axis_type,
    x_axis_order=x_axis_order
) }}
{% else %}
{% if axis_type == 'categorical' %}
with base_query as (
    {{ base_query | indent }}
)
select
    {{ x_axis }}_min as {{ x_axis }},
    {% for metric_name in metric_names %}
    {{ metric_name }}{{ ',' if not loop.last }}
    {% endfor %}
from base_query
{% else %}
{{ base_query }}
{% endif %}
{% endif %}
