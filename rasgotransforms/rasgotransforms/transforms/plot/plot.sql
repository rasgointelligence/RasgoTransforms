{% from 'aggregate_metrics.sql' import calculate_timeseries_metric_values, calculate_continuous_metric_values, calculate_categorical_metric_values %}
{% from 'expression_metrics.sql' import calculate_expression_metric_values %}
{% from 'distinct_values.sql' import get_distinct_vals %}
{% from 'pivot.sql' import pivot_plot_values %}
{% from 'filter.sql' import get_filter_statement, combine_filters %}
{% from 'secondary_calculation.sql' import render_secondary_calculations, adjust_start_date %}
{% set dimensions = dimensions if dimensions is defined else [] %}
{% set max_num_groups = max_num_groups if max_num_groups is defined else 10 %}
{% set bucket_count = x_axis.bucket_count if x_axis.bucket_count is defined else 200 %}
{% set filters = filters if filters is defined else [] %}
{% if x_axis.type == 'timeseries' %}
{% if x_axis.timeseries_options %}
{% set start_date = '2010-01-01' if not x_axis.timeseries_options.start_date else x_axis.timeseries_options.start_date %}
{% set end_date = ((start_date|string|todatetime).now().date()|string) if not x_axis.timeseries_options.end_date else x_axis.timeseries_options.end_date%}
{% set time_grain = 'day' if not x_axis.timeseries_options.time_grain else x_axis.timeseries_options.time_grain %}
{% else %}
{{ raise_exception("Parameter 'x_axis.timeseries_options' must be given when 'x_axis' is a column of type datetime")}}
{% endif %}
{% set num_days = (end_date|string|todatetime - start_date|string|todatetime).days + 1 %}
{% endif %}
{% set column_agg_list = aggregations %}

{% set metric_names = [] %}
{% set aggregations = [] %}
{% for column, agg_methods in column_agg_list.items() %}
{% for agg_method in agg_methods %}
{% set metric_name = cleanse_name(column + '_' + agg_method) %}
{% do aggregations.append({
    'column': column,
    'method': agg_method,
    'alias': metric_name
}) %}
{% do metric_names.append(metric_name) %}
{% endfor %}
{% endfor %}

{% if dimensions %}
{% if start_date is defined %}
{% set date_filter %}
({{ x_axis.column }} >= '{{ start_date }}' AND {{ x_axis.column }} <= '{{ end_date }}')
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
    target_metric=aggregations[0] if aggregations else None,
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
{% if x_axis.type == 'timeseries' %}
with aggregations as (
    {{ calculate_timeseries_metric_values(
        aggregations=aggregations,
        time_dimension=x_axis.column,
        dimensions=dimensions,
        start_date=start_date,
        end_date=end_date,
        time_grain=time_grain,
        source_table=source_table,
        filters=filters,
        distinct_values=distinct_values
    ) | indent }}
)
{% set dimensions = ['dimensions'] if dimensions %}
select
    period_min as {{ x_axis.column }}_min,
    period_max as {{ x_axis.column }}_max,
    {% for dimension in dimensions %}
    {{ dimension }},
    {% endfor %}
    {% for name in metric_names %}
    {{ name }}{{ ',' if not loop.last }}
    {% endfor %}
from aggregations
order by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n' }}{% endfor %}
{# Numeric Axis #}
{% elif x_axis.type == 'numeric' %}
{{ calculate_continuous_metric_values(
    aggregations=aggregations,
    x_axis=x_axis.column,
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
    x_axis=x_axis.column,
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
    x_axis=x_axis.column,
    metric_names=metric_names,
    distinct_values=distinct_values,
    axis_type=x_axis.type,
    x_axis_order=x_axis_order
) }}
{% else %}
{% if x_axis.type == 'categorical' %}
with base_query as (
    {{ base_query | indent }}
)
select
    {{ x_axis.column }}_min as {{ x_axis.column }},
    {% for metric_name in metric_names %}
    {{ metric_name }}{{ ',' if not loop.last }}
    {% endfor %}
from base_query
{% else %}
{{ base_query }}
{% endif %}
{% endif %}
