{% if items is not defined %}
    {% if filter_statements is not defined %}
        {{ raise_exception('items is empty: there are no filters to apply') }}
    {% else %}
        {% set items = filter_statements %}
    {% endif %}
{% endif %}
{% set logical_operator = namespace(value='AND') %}
{% for filter_block in items %}
    {% if filter_block is mapping and 'compoundBoolean' in filter_block %}
        {% set logical_operator.value = filter_block['compoundBoolean'] %}
    {% endif %}
{% endfor %}

SELECT *
FROM {{ source_table }}
WHERE
{% for filter_block in items %}
{% set oloop = loop %}
    {% if filter_block is not mapping %}
    {{ logical_operator.value if not loop.first}} {{ filter_block }}
    {% else %}
        {% if filter_block['operator'] == 'CONTAINS' %}
    {{ logical_operator.value if not loop.first}} {{ filter_block['operator'] }}({{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }})
        {% else %}
    {{ logical_operator.value if not loop.first}} {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
        {% endif %}
    {% endif %}
{% endfor %}