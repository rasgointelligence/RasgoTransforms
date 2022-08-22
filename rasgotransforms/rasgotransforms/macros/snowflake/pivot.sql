{% macro pivot_plot_values(
    base_query,
    x_axis,
    metric_names,
    distinct_values,
    axis_type,
    x_axis_order
) %}
with
    base_query as (
        {{ base_query | indent(8) }}
    ),
    {% set column_names = [] %}
    {% for metric_name in metric_names %}
    pivoted__{{ metric_name }} as (
        select
            x_min_{{ metric_name }},
            x_max_{{ metric_name }},
            {% for val in distinct_values %}
            {% set column_name = cleanse_name(val) + '_' + metric_name %}
            {% do column_names.append(column_name) %}
            {{ column_name }}{{',' if not loop.last else ''}}
            {% endfor %}
        from (
            select
                {{ x_axis }}_min,
                {{ x_axis }}_max,
                {{ metric_name }},
                dimensions
            from base_query
        )
        pivot (
            sum({{ metric_name }}) for dimensions in (
                {% for val in distinct_values %}
                '{{ val }}'{{',' if not loop.last else ''}}
                {% endfor %}
            )
        ) as p (
            x_min_{{ metric_name }},
            x_max_{{ metric_name }},
            {% for val in distinct_values %}
            {{ cleanse_name(val) + '_' + metric_name }}{{',' if not loop.last else ''}}
            {% endfor %}
        )
    ),
    {% endfor %}
    pivoted as (
        select *
        from pivoted__{{ metric_names[0] }}
            {% for i in range(1, metric_names|length) %}
            left join pivoted__{{ metric_names[i] }}
                on x_min_{{ metric_names[0] }} = x_min_{{ metric_names[i] }}
                and x_max_{{ metric_names[0] }} = x_max_{{ metric_names[i] }}
            {% endfor %}
    )
select
    {% if axis_type == 'categorical' %}
    x_min_{{ metric_names[0] }} as {{ x_axis }},
    {% else %}
    x_min_{{ metric_names[0] }} as {{ x_axis }}_min,
    x_max_{{ metric_names[0] }} as {{ x_axis }}_max,
    {% endif %}
    {% for column_name in column_names %}
    {{ column_name }}{{ ',' if not loop.last }}
    {% endfor %}
from pivoted order by 1 {{ x_axis_order if x_axis_order }}
{% endmacro %}
