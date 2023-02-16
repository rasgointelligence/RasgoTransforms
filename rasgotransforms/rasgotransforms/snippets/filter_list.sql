{% set filters = filter_list %}
{% from 'filter.sql' import get_filter_statement %}
{{ get_filter_statement(filters) }}