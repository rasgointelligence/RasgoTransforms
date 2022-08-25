{% macro get_filter_statement(filters) %}
{% if filters %}
{% if filters is string %}
{{ filters }}
{% else %}
{% set logical_operator = namespace(value='AND') %}
{% for filter in filters %}
    {% if filter is mapping and 'compoundBoolean' in filter %}
        {% set logical_operator.value = filter['compoundBoolean'] %}
    {% endif %}
{% endfor %}
where
    {% for filter in filters %}
    {% if filter is not mapping %}
    {{ logical_operator.value if not loop.first}} {{ filter }}
    {% elif filter.operator|upper == 'CONTAINS' %}
    {{ logical_operator.value if not loop.first}} {{ filter.operator }}({{ filter.columnName }}, {{ filter.comparisonValue }})
    {% else %}
    {{ logical_operator.value if not loop.first}} {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
    {% endif %}
    {% endfor %}
{% endif %}
{% endif %}
{% endmacro %}


{% macro get_metric_filter_statement(x_axis, start_date, end_date, filters) %}
{% set logical_operator = namespace(value='AND') %}
{% for filter in filters %}
{% if filter is mapping and 'compoundBoolean' in filter %}
    {% set logical_operator.value = filter['compoundBoolean'] %}
{% endif %}
{% endfor %}
where ({{ x_axis }} >= '{{ start_date }}' AND {{ x_axis }} <= '{{ end_date }}') {{ 'AND' if filters }}
    {% if filters %}
    (
    {% for filter in filters %}
    {% if filter is not mapping %}
    {{ logical_operator.value if not loop.first}} {{ filter }}
    {% elif filter.operator|upper == 'CONTAINS' %}
    {{ logical_operator.value if not loop.first}} {{ filter.operator }}({{ filter.columnName }}, {{ filter.comparisonValue }})
    {% else %}
    {{ logical_operator.value if not loop.first}} {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
    {% endif %}
    {% endfor %}
    )
    {% endif %}
{% endmacro %}
