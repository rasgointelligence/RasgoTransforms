{% from 'metrics.sql' import calculate_timeseries_metric_values, get_distinct_vals %}
{% set start_date = '2010-01-01' if not start_date else start_date|string %}
{% set end_date = '2030-01-01' if not end_date else end_date|string %}
{% set alias = 'metric_value' if not alias else alias %}
{% set max_num_groups = max_num_groups if max_num_groups is defined else 10 %}
{% set filters = filters if filters is defined else [] %}
{% do filters.append({'columnName': time_dimension, 'operator': '>=', 'comparisonValue': "'" + start_date + "'" }) %}
{% do filters.append({'columnName': time_dimension, 'operator': '<=', 'comparisonValue': "'" + end_date + "'" }) %}

{% set distinct_vals = (
    get_distinct_vals(
        columns=dimensions,
        target_metric=metrics[0],
        max_vals=max_num_groups,
        source_table=source_table,
        filters=filters
    )
    | from_json if dimensions else []
) %}

with metric_values as (
    {{
        calculate_timeseries_metric_values(
            metrics=metrics,
            time_dimension=time_dimension,
            dimensions=dimensions,
            start_date=start_date,
            end_date=end_date,
            time_grain=time_grain,
            source_table=source_table,
            filters=filters,
            distinct_vals=distinct_vals
        ) | indent
    }}
) select
    {{ time_dimension }}_min,
    {{ time_dimension }}_max,
    {% if dimensions %}
    dimensions,
    {% endif %}
    {{ target_expression }} as {{ alias }}
from metric_values

{{ context }}

