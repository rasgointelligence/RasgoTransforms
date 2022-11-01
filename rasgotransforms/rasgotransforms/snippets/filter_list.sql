{% set filters = filter_list %}
{% if filters %}
{% set filters = {'filters': filters, 'logical_operator': 'and' } %}
{% for filter in filters.filters %}
    {% if filter is not string %}
        {% if filter is mapping and 'compoundBoolean' in filter and filter['compoundBoolean'] %}
            {% do filters.__setitem__('logical_operator', filter['compoundBoolean']) %}
        {% endif %}
    {% endif %}
{% endfor %}
(
    {% for filter in filters.filters %}
    {% if filter is not mapping %}
    {{ filters.logical_operator + ' ' if not loop.first }}{{ filter }}
    {% elif filter.operator|upper == 'CONTAINS' %}
    {{ filters.logical_operator.value + ' ' if not loop.first }}{{ filter.column_name }} like '%{{ filter.comparison_value }}%'
    {% else %}
    {{ filters.logical_operator + ' ' if not loop.first }}{{ filter.column_name }} {{ filter.operator }} {{ filter.comparison_value }}
    {% endif %}
    {% endfor %}
)
{% else %}
true
{% endif %}