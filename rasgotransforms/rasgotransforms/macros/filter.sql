{% macro get_filter_group(filters) %}

{% for filter in filters %}
{% set condition = filter.condition + ' ' if not loop.first else '' %}
{% if filter.type == 'sql' %}
{{ condition }}{{ filter.value }}
{% elif filter.type == 'object' %}
{% if filter.operator|upper == 'CONTAINS' %}
{{ condition}}{{ filter.value.operator }}({{ filter.value.columnName }}, {{ filter.value.comparisonValue }})
{% else %}
{{ condition}}{{ filter.value.columnName }} {{ filter.value.operator }} {{ filter.value.comparisonValue }}
{% endif %}
{% elif filter.type == 'group' %}
{{ condition }}(
        {{ get_filter_group(filter.value) | indent(8) }}
    )
{% endif %}
{% endfor %}

{% endmacro %}


{% macro get_filter_statement(filters) %}
{% if filters %}
{{ get_filter_group(filters) }}
{% else %}
true
{% endif %}
{% endmacro %}
