{% macro period_to_date(metric_name, dimensions, calc_config) %}
{% set alias = metric_name + '_' + calc_config.alias if calc_config.alias is defined else metric_name + '_' + calc_config.aggregate + '_' + calc_config.period %}
{{ calc_config.aggregate }}({{ metric_name }})
over (
    partition by
    {% if dw_type() == 'bigquery' %}
        date_trunc(period_min, {{ calc_config.period }})
    {% else %}
        date_trunc('{{ calc_config.period }}', period_min)
    {% endif %}
    {% if dimensions %}
        , {{ dimensions | join(", ") }}
    {% endif %}
    order by period_min
    rows between unbounded preceding and current row
) as {{ alias }}
{% endmacro %}
