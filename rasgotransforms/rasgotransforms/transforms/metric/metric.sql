{% from 'aggregate_metrics.sql' import calculate_timeseries_metric_values %}
{% from 'expression_metrics.sql' import calculate_expression_metric_values %}
{% from 'combine_groups.sql' import combine_groups %}
{% if not start_date %}
{% set start_date_query %}
select min(cast({{ time_dimension }} as date)) start_date from {{ source_table }}
{% endset %}
{% set start_date_query_result = run_query(start_date_query) %}
{% if start_date_query_result is none %}
{{ raise_exception('start_date must be provided when no Data Warehouse connection is available')}}
{% endif %}
{% set start_date = start_date_query_result[start_date_query_result.columns[0]][0]|string %}
{% else %}
{% set start_date = start_date|string %}
{% endif %}
{% set target_expression = target_column if not target_expression else target_expression %}
{% set type = aggregation if not type else type %}
{% if not end_date %}
{% set end_date = ((start_date|string|todatetime).now().date())|string %}
{% else %}
{% set end_date = end_date|string %}
{% endif %}
{% set name = cleanse_name(type + '_' + target_expression) if not (name or alias) else name %}
{% set name = name if not alias else cleanse_name(alias) %}
{% set filters = filters if filters is defined else [] %}

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