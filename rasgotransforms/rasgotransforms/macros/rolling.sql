{% macro rolling(metric_name, dimensions, calc_config) %}
{% set alias = metric_name + '_' + calc_config.alias if calc_config.alias is defined else metric_name + calc_config.aggregate + '_last_' + calc_config.interval|string + '_periods' %}
{{ calc_config.aggregate }}({{ metric_name }})
over (
    {% if dimensions -%}
        partition by {{ dimensions | join(", ") }}
    {% endif -%}
    order by period_min
    rows between {{ calc_config.interval - 1 }} preceding and current row
) as {{ alias }}
{% endmacro %}
