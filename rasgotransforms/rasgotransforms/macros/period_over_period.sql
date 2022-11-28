{% macro period_over_period(metric_name, dimensions, calc_config, metric_config) %}
{% set alias = metric_name + '_' + calc_config.alias if calc_config.alias is defined else metric_name + '_pop_' + calc_config.comparison_strategy + '_' + calc_config.interval|string %}
{% set calc_sql %}
lag(
    {{ metric_name }}, {{ calc_config.interval }}
) over (
    {% if dimensions %}
        partition by {{ dimensions | join(", ") }}
    {% endif %}
    order by period_min
)
{% endset%}

{% if calc_config.comparison_strategy == 'difference' %}
{{ metric_comparison_strategy_difference(metric_name, calc_sql, metric_config) }}
{% elif calc_config.comparison_strategy == 'ratio' %}
{{ metric_comparison_strategy_ratio(metric_name, calc_sql, metric_config) }}
{% else %}
{{ raise_exception("Bad comparison_strategy for period_over_period: " ~ calc_config.comparison_strategy) }}
{% endif %}
    as {{ alias }}
{% endmacro %}

{% macro metric_comparison_strategy_difference(metric_name, calc_sql, metric_config) %}
{% if not metric_config.get("treat_null_values_as_zero", True) %}
{{ metric_name }} - {{ calc_sql }}
{% else %}
coalesce({{ metric_name }}, 0) - coalesce(
    {{ calc_sql | indent }}
, 0)
{% endif %}
{% endmacro %}

{% macro metric_comparison_strategy_ratio(metric_name, calc_sql, metric_config) %}
{% if not metric_config.get("treat_null_values_as_zero", True) %}
cast({{ metric_name }} as numeric) / nullif(
    {{ calc_sql | indent }}
, 0)
{% else %}
coalesce(
    cast({{ metric_name }} as numeric) / nullif(
        {{ calc_sql | indent(8) }}
    , 0)
, 0)
{% endif %}
{% endmacro %}
