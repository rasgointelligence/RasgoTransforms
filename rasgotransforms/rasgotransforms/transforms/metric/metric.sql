{% from 'aggregate_metrics.sql' import calculate_timeseries_metric_values %}
{% from 'expression_metrics.sql' import calculate_expression_metric_values %}
{% from 'combine_groups.sql' import combine_groups %}
{% set start_date = '2010-01-01' if not start_date else start_date|string %}
{% set end_date = '2030-01-01' if not end_date else end_date|string %}
{% set alias = 'metric_value' if not alias else alias %}
{% set max_num_groups = max_num_groups if max_num_groups is defined else 10 %}
{% set filters = filters if filters is defined else [] %}
{% do filters.append({'columnName': time_dimension, 'operator': '>=', 'comparisonValue': "'" + start_date + "'" }) %}
{% do filters.append({'columnName': time_dimension, 'operator': '<=', 'comparisonValue': "'" + end_date + "'" }) %}

{% if type|lower == 'expression' %}

{{ calculate_expression_metric_values(
    name=name,
    metrics=metric_dependencies,
    target_expression=target_expression,
    dimensions=dimensions,
    start_date=start_date,
    end_date=end_date,
    time_grain=time_grain
) }}

{% else %}

{{ calculate_timeseries_metric_values(
    aggregations=[{
        'column': target_expression,
        'method': type,
        'alias': name
    }],
    time_dimension=time_dimension,
    dimensions=dimensions,
    start_date=start_date,
    end_date=end_date,
    time_grain=time_grain,
    source_table=source_table,
    filters=filters
) }}

{% endif %}