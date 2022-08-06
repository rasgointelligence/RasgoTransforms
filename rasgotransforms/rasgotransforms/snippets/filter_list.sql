{%- for filter in filter_list %}
    {%- if filter is not mapping %}
        and {{ filter }}
    {%- elif filter.operator|upper == 'CONTAINS' %}
        and {{ filter.operator }}({{ filter.column_name }}, {{ filter.comparison_value }})
    {%- else %}
        and {{ filter.column_name }} {{ filter.operator }} {{ filter.comparison_value }}
    {%- endif %}
{%- endfor %}