{% from 'period_over_period.sql' import period_over_period %}
{% from 'period_to_date.sql' import period_to_date %}
{% from 'rolling.sql' import rolling %}
{% from 'prior.sql' import prior %}

{% macro render_secondary_calculations(metric_names, secondary_calculations, dimensions) %}
{% do set_secondary_calculation_aliases(secondary_calculations) %}
{% if secondary_calculations %}
{% for calc_config in secondary_calculations %}
{% for metric_name in metric_names %}
{% if calc_config.metric_names is undefined or metric_name in calc_config.metric_names %}
{% if calc_config.type == 'period_over_period' %}
,{{ period_over_period(
    metric_name=metric_name,
    dimensions=dimensions,
    calc_config=calc_config,
    metric_config={}
) }}
{% elif calc_config.type == 'period_to_date' %}
,{{ period_to_date(
    metric_name=metric_name,
    dimensions=dimensions,
    calc_config=calc_config
) }}
{% elif calc_config.type == 'rolling' %}
,{{ rolling(
    metric_name=metric_name,
    dimensions=dimensions,
    calc_config=calc_config
) }}
{% elif calc_config.type == 'prior' %}
,{{ prior(
    metric_name=metric_name,
    dimensions=dimensions,
    calc_config=calc_config
) }}
{% endif %}
{% endif %}
{% endfor %}
{% endfor %}
{% endif %}
{% endmacro %}

{% macro set_secondary_calculation_aliases(secondary_calculations) %}
{% for calc_config in secondary_calculations %}
    {% if not calc_config.alias is defined %}
        {% if calc_config.type == 'period_over_period' %}
            {% set alias = 'pop_' + calc_config.comparison_strategy + '_' + calc_config.interval|string %}
        {% elif calc_config.type == 'period_to_date' %}
            {% set alias = calc_config.aggregate + '_' + calc_config.period %}
        {% elif calc_config.type == 'rolling' %}
            {% set alias = calc_config.aggregate + '_last_' + calc_config.interval|string + '_periods' %}
        {% elif calc_config.type == 'prior' %}
             {% set alias = 'lag_' + calc_config.interval|string %}
        {% else %}
            {% set alias = calc_config.type %}
        {% endif %}
        {% do calc_config.__setitem__('alias', alias) %}
    {% endif %}
{% endfor %}
{% endmacro %}
