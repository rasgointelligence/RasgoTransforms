{% from 'aggregate_metrics.sql' import calculate_timeseries_metric_values %}

{% macro calculate_expression_metric_values(
    name,
    metrics,
    target_expression,
    dimensions,
    start_date,
    end_date,
    time_grain
) %}
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

{#{% set base_query %}#}
with
{% for metric in metrics %}
    {{ metric.name }}__values as (
        {{ calculate_timeseries_metric_values(
            aggregations=[{
                'column': metric.target_expression,
                'method': metric.type,
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
{#{% endset %}#}

{#{{ combine_groups(#}
{#        query=base_query,#}
{#        keep_columns=['period_min', 'period_max', name],#}
{#        dimensions=dimensions,#}
{#        max_num_groups=max_num_groups,#}
{#        target_metric={#}
{#            'column': name,#}
{#            'agg_method': 'max'#}
{#        }#}
{#) }}#}
{% endmacro %}
