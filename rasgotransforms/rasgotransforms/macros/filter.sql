{% macro get_filter_statement(filters) %}
{% if filters %}
where true
    {% for filter in filters %}
    {% if filter is not mapping %}
    and {{ filter }}
    {% elif filter.operator|upper == 'CONTAINS' %}
    and {{ filter.operator }}({{ filter.columnName }}, {{ filter.comparisonValue }})
    {% else %}
    and {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
    {% endif %}
    {% endfor %}
{% endif %}
{% endmacro %}
