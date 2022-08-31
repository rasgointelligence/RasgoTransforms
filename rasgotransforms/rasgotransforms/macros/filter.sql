{% macro get_filter_statement(filters) %}
{% if filters %}
{% if filters is string %}
{{ filters }}
{% else %}
{% set logical_operator = namespace(value='AND') %}
{% for filter in filters %}
    {% if filter is not string %}
        {% if filter is not mapping %}
            {% set filter = dict(filter) %}
        {% endif %}
        {% if filter is mapping and 'compoundBoolean' in filter and filter['compoundBoolean'] %}
            {% set logical_operator.value = filter['compoundBoolean'] %}
        {% endif %}
    {% endif %}
{% endfor %}
(
    {% for filter in filters %}
    {% if filter is not string and filter is not mapping %}
    {% set filter = dict(filter) %}
    {% endif %}
    {% if filter is not mapping %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter }}
    {% elif filter.operator|upper == 'CONTAINS' %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter.operator }}({{ filter.columnName }}, {{ filter.comparisonValue }})
    {% else %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
    {% endif %}
    {% endfor %}
)
{% endif %}
{% else %}
true
{% endif %}
{% endmacro %}
