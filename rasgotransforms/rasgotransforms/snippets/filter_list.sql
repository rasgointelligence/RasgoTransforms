{% if filter_list %}
{% set filter_list = {'filters': filter_list, 'logical_operator': 'and' } %}
{% for filter in filter_list.filters %}
    {% if filter is not string %}
        {% if filter is mapping and 'compoundBoolean' in filter and filter['compoundBoolean'] %}
            {% do filter_list.__setitem__('logical_operator', filter['compoundBoolean']) %}
        {% endif %}
    {% endif %}
{% endfor %}
(
    {% for filter in filter_list.filters %}
    {% if filter is not mapping %}
    {{ filter_list.logical_operator + ' ' if not loop.first }}{{ filter }}
    {% elif filter.operator|upper == 'CONTAINS' %}
    {{ filter_list.logical_operator + ' ' if not loop.first }}{{ filter.operator }}({{ filter.columnName }}, {{ filter.comparisonValue }})
    {% else %}
    {{ filter_list.logical_operator + ' ' if not loop.first }}{{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
    {% endif %}
    {% endfor %}
)
{% else %}
true
{% endif %}