{% macro get_filter_group(filters) %}

{% for filter in filters %}
{% set condition = filter.condition + ' ' if not loop.first else '' %}
{% if filter.type|lower == 'sql' %}
{{ condition }}{{ filter.value }}
{% elif filter.type|lower == 'object' %}
{% if filter.operator|lower == 'contains' %}
{{ condition}}{{ filter.value.operator }}({{ filter.value.columnName }}, {{ filter.value.comparisonValue }})
{% else %}
{{ condition}}{{ filter.value.columnName }} {{ filter.value.operator }} {{ filter.value.comparisonValue }}
{% endif %}
{% elif filter.type|lower == 'group' %}
{{ condition }}(
        {{ get_filter_group(filter.value) | indent(8) }}
    )
{% endif %}
{% endfor %}

{% endmacro %}

{% macro get_old_filter_statement(filters) %}
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

{% macro get_filter_statement(filters) %}
{% if filters %}
{% if 'condition' not in filters[0] %}
{{ get_old_filter_statement(filters) }}
{% else %}
{{ get_filter_group(filters) }}
{% endif %}
{% else %}
true
{% endif %}
{% endmacro %}
