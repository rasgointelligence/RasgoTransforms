{% macro prior(metric_name, dimensions, calc_config) %}
{% set alias = metric_name + '_' + calc_config.alias if calc_config.alias is defined else metric_name + '_lag_' + calc_config.interval|string %}
lag(
    {{ metric_name }}, {{ calc_config.interval }}
) over (
    {% if dimensions %}
        partition by {{ dimensions | join(", ") }}
    {% endif %}
    order by period_min
) as {{ alias }}
{% endmacro %}
