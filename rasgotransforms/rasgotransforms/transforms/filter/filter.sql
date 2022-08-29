{% from 'filter.sql' import get_filter_statement %}
{% if items is not defined %}
    {% if filter_statements is not defined %}
        {{ raise_exception('items is empty: there are no filters to apply') }}
    {% else %}
        {% set items = filter_statements %}
    {% endif %}
{% endif %}

select *
from {{ source_table }}
where true and
    {{ get_filter_statement(items) | indent }}
