{% from 'aggregate_metrics.sql' import calculate_timeseries_metric_values %}
{% from 'expression_metrics.sql' import calculate_expression_metric_values %}
{% from 'distinct_values.sql' import get_distinct_vals %}
{% from 'pivot.sql' import pivot_plot_values %}
{% from 'filter.sql' import get_filter_statement, combine_filters %}
{% from 'secondary_calculation.sql' import render_secondary_calculations %}
{% set dimensions = group_by_dimensions if group_by_dimensions is defined else [] %}
{% set max_num_groups = max_num_groups if max_num_groups is defined else 10 %}
{% set filters = filters if filters is defined else [] %}
{% set expression_metric_names = [] %}
{% set expression_metrics = [] %}
{% set secondary_calculations = [] %}
{% if not metrics %}
{{ raise_exception('Please select at least one metric to compare') }}
{% endif %}
{% for comparison in metrics %}
    {% if comparison.name not in expression_metric_names %}
        {% do expression_metric_names.append(comparison.name) %}
        {% do expression_metrics.append(comparison) %}
    {% endif %}
    {% if comparison.secondary_calculation is defined and comparison.secondary_calculation.type|lower != 'default' %}
        {% do comparison.secondary_calculation.__setitem__('metric_names', [comparison.name]) %}
        {% do secondary_calculations.append(comparison.secondary_calculation) %}
    {% endif %}
{% endfor %}
{% set original_start_date = parse_comparison_value(timeseries_options.start_date) %}
{% set end_date = 'CURRENT_DATE' if not timeseries_options.end_date else parse_comparison_value(timeseries_options.end_date) %}
{% set time_grain = 'day' if not timeseries_options.time_grain else timeseries_options.time_grain %}
{% set start_date = adjust_start_date(start_date=timeseries_options.start_date, time_grain=time_grain, secondary_calculations=secondary_calculations) %}

{% set table_metrics = {} %}
{% set metric_names = [] %}
{% set aggregations = [] %}

{% if dimensions %}
{% set source_tables = []|to_set %}
{% for comparison in metrics %}
{% if comparison.type == 'expression' %}
{% for dep in comparison.metric_dependencies %}
{% if 'sourceTable' in dep %}
{% do dep.__setitem__('source_table', dep.sourceTable) %}
{% endif %}
{% do source_tables.add(dep.source_table) %}
{% endfor %}
{% else %}
{% if 'sourceTable' in comparison %}
{% do comparison.__setitem__('source_table', comparison.sourceTable) %}
{% endif %}
{% do source_tables.add(comparison.source_table) %}
{% endif %}
{% endfor %}
{% if source_tables|length != 1 %}
{{ raise_exception('Cannot add dimensions when comparing metrics with different source tables') }}
{% endif %}
{% set source_table = source_tables.pop() %}
{% if 'timeDimension' in metrics[0] %}
{% do metrics[0].__setitem__('time_dimension', metrics[0].timeDimension) %}
{% endif %}
{% set date_filter %}
({{ metrics[0].time_dimension }} >= {{ start_date }} AND {{ metrics[0].time_dimension }} <= {{ end_date }})
{% endset %}
{% set distinct_vals_filters = get_filter_statement([
    date_filter,
    get_filter_statement(filters)
]) if start_date is defined and metrics[0].type|lower != 'expression' else filters %}

{% set distinct_values = get_distinct_vals(
    columns=dimensions,
    target_metric=None,
    max_vals=max_num_groups,
    source_table=source_table,
    filters=distinct_vals_filters
) | from_json %}
{% if distinct_values is not defined or not distinct_values %}
    {{ raise_exception('This query returns 0 rows. Please adjust the inputs and try again.') }}
{% endif %}
{% endif %}

{% set base_query %}
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

{# Join expression and aggregation metrics #}
{% set dimensions = ['dimensions'] if dimensions %}
{% set tables = table_metrics.keys()|list %}
joined as (
    select
        {{ tables[0] }}.period_min,
        {{ tables[0] }}.period_max,
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
),
secondary_calculations as (
    select
        period_min,
        period_max,
        {% for dimension in dimensions %}
        {{ dimension }},
        {% endfor %}
        {% for metric_name in metric_names %}
        {{ metric_name }}{{ ',' if not loop.last }}
        {% endfor %}
        {{ render_secondary_calculations(
            metric_names=metric_names,
            secondary_calculations=secondary_calculations,
            dimensions=dimensions
        ) | indent(8) }}
    from joined
)
select * from secondary_calculations
where period_min >= {{ original_start_date }}
order by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n' }}{% endfor %}
{% set secondary_calculation_metrics = [] %}
{% for calc_config in secondary_calculations %}
{% set calc_metric_names = calc_config.metric_names or metric_names %}
{% for metric_name in calc_metric_names %}
{% do secondary_calculation_metrics.append(metric_name + '_' + calc_config.alias) %}
{% endfor %}
{% endfor %}
{% do metric_names.extend(secondary_calculation_metrics) %}
{% endset %}

{% if dimensions %}
{{ pivot_plot_values(
    base_query=base_query,
    x_axis='period',
    metric_names=metric_names,
    distinct_values=distinct_values,
    axis_type=axis_type,
    x_axis_order=x_axis_order
) }}
{% else %}
{{ base_query }}
{% endif %}
