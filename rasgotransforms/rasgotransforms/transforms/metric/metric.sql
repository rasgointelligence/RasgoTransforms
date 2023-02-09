{% from 'aggregate_metrics.sql' import calculate_timeseries_metric_values %}
{% from 'expression_metrics.sql' import calculate_expression_metric_values %}
{% from 'pivot.sql' import pivot_plot_values %}
{% from 'filter.sql' import get_filter_statement, combine_filters %}
{% from 'secondary_calculation.sql' import render_secondary_calculations %}
{% set dimensions = group_by_dimensions if group_by_dimensions is defined else [] %}
{% set filters = filters if filters is defined else [] %}
{% set unique_metric_names = [] %}
{% set unique_metrics = [] %}
{% set secondary_calculations = [] %}
{% if metrics %}
    {% set metrics = cleanse_keys(metrics) %}
{% else %}
    {{ raise_exception('Please select at least one metric to compare') }}
{% endif %}

{% for comparison in metrics %}
    {% if 'resource_key' in comparison %}
        {# Lookup metric if receiving key instead of metric dict #}
        {% do comparison.update(ref_metric(comparison.resource_key)) %}
    {% endif %}
    {% if comparison.name not in unique_metric_names %}
        {% do unique_metric_names.append(comparison.name) %}
        {% do unique_metrics.append(comparison) %}
    {% endif %}
    {% if comparison.secondary_calculation is defined and comparison.secondary_calculation.type|lower != 'default' %}
        {% do comparison.secondary_calculation.__setitem__('metric_names', [comparison.name]) %}
        {% do secondary_calculations.append(comparison.secondary_calculation) %}
    {% endif %}
{% endfor %}
{% if date_settings.start_date == '' %}
{% do date_settings.__setitem__('start_date', '1900-01-01') %}
{% endif %}
{% set original_start_date = parse_comparison_value(date_settings.start_date) %}
{% set end_date = 'CURRENT_DATE' if not date_settings.end_date else parse_comparison_value(date_settings.end_date) %}
{% set time_grain = 'day' if not date_settings.time_grain else date_settings.time_grain %}
{% if time_grain|lower == 'all' and secondary_calculations|length > 0 %}
{{ raise_exception("Secondary calculations are not allowed when the time grain is 'all'") }}
{% endif %}
{% set start_date = adjust_start_date(start_date=date_settings.start_date, time_grain=time_grain, secondary_calculations=secondary_calculations) %}
{% set unique_metrics = combine_metrics(unique_metrics) %}

{% set table_metrics = {} %}
{% set metric_names = [] %}

{% if dimensions %}
{% set source_tables = []|to_set %}
{% for comparison in metrics %}
{% if comparison.type == 'expression' %}
{% for dep in comparison.metric_dependencies %}
{% do source_tables.add(dep.source_table) %}
{% endfor %}
{% else %}
{% do source_tables.add(comparison.source_table) %}
{% endif %}
{% endfor %}
{% if source_tables|length != 1 %}
{{ raise_exception('Cannot add dimensions when comparing metrics with different source tables') }}
{% endif %}
{% set source_table = source_tables.pop() %}
{% set date_filter %}
({{ metrics[0].time_dimension }} >= {{ start_date }} AND {{ metrics[0].time_dimension }} <= {{ end_date }})
{% endset %}
{% set distinct_vals_filters = get_filter_statement([
    date_filter,
    get_filter_statement(filters)
]) if start_date is defined and metrics[0].type|lower != 'expression' else filters %}
{% endif %}

with
{% for metric in unique_metrics %}
{% do metric_names.extend(metric.names) %}
{% do table_metrics.__setitem__('metric__' + metric.name, metric.names) %}
metric__{{ metric.name }} as (
    {# Expression Metrics #}
    {% if metric.type|lower == 'expression' %}
    {{ calculate_expression_metric_values(
        name=metric.name,
        metrics=metric.metric_dependencies,
        target_expression=metric.target_expression,
        dimensions=dimensions,
        start_date=start_date,
        end_date=end_date,
        time_grain=time_grain,
        filters=combine_filters(metric.filters, filters)
    ) | indent }}
    {% else %}
    {# Normal Metrics #}
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
        filters=combine_filters(metric.filters, filters)
    ) | indent }}
    {% endif %}
),
{% endfor %}

{# Join expression and aggregation metrics #}
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
