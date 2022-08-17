{% from 'aggregate_metrics.sql' import calculate_timeseries_metric_values %}
{% set start_date = '2010-01-01' if not start_date else start_date|string %}
{% set end_date = '2030-01-01' if not end_date else end_date|string %}
{% set alias = 'metric_value' if not alias else alias %}
{% set max_num_groups = max_num_groups if max_num_groups is defined else 10 %}
{% set filters = filters if filters is defined else [] %}
{% do filters.append({'columnName': time_dimension, 'operator': '>=', 'comparisonValue': "'" + start_date + "'" }) %}
{% do filters.append({'columnName': time_dimension, 'operator': '<=', 'comparisonValue': "'" + end_date + "'" }) %}

{% set dimensions_by_table = {} %}
{% for metric in metrics %}
    {% if dimensions %}
        {% if metric.source_table not in dimensions_by_table %}
            {% set columns = get_columns(metric.source_table) %}
            {% for dimension in dimensions %}
                {% if dimension in columns %}
                    {% do dimensions_by_table.setdefault(metric.source_table, []).append(dimension) %}
                {% endif %}
            {% endfor %}
        {% endif %}
        {% do metric.__setitem__('dimensions', dimensions_by_table[metric.source_table]) %}
    {% else %}
        {% do metric.__setitem__('dimensions', []) %}
    {% endif %}
{% endfor %}

with
{% if type|lower == 'expression' %}
{% for metric in metrics %}
    {{ metric.name }}__values as (
        {{ calculate_timeseries_metric_values(
            metrics=[{
                'column': metric.target_expression,
                'agg_method': metric.type,
                'alias': metric.name
            }],
            time_dimension=metric.time_dimension,
            dimensions=metric.dimensions,
            start_date=start_date,
            end_date=end_date,
            time_grain=time_grain,
            source_table=metric.source_table,
            filters=metric.filters
            ) | indent
        }}
    ),
{% endfor %}
    joined as (
        select
            m0.period_min,
            m0.period_max,
            {% for dimension in dimensions %}
            {% set break = {'value': false} %}
            {% for i in range(metrics|length) %}
            {% if dimension in metrics[i].dimensions and not break['value'] %}
            {% do break.__setitem__('value', true) %}
            m{{ i }}.{{ dimension }},
            {% endif %}
            {% endfor %}
            {% endfor %}
            {% for metric in metrics %}
            {{ metric.name }}{{ ',' if not loop.last }}
            {% endfor %}
        from {{ metrics[0].name }}__values m0
        {% for i in range(1, metrics|length) %}
        left join {{ metrics[i].name }}__values m{{ i }}
            on m0.period_min = m{{ i }}.period_min
            {% for j in range(i) %}
            {% set common_dimensions = (metrics[i].dimensions|to_set).intersection(metrics[j].dimensions|to_set) %}
            {% for dimension in common_dimensions %}
            and m{{ j }}.{{ dimension }} = m{{ i }}.{{ dimension }}
            {% endfor %}
            {% endfor %}
        {% endfor %}
    )
    select
        period_min,
        period_max,
        {% for dimension in dimensions %}
        {{ dimension }},
        {% endfor %}
        {{ target_expression }} as {{ name }}
    from joined
    order by {% for i in range(1, 3 + dimensions|length) %}{{ i }}{{ ',' if not loop.last else '\n' }}{% endfor %}
{% endif %}
