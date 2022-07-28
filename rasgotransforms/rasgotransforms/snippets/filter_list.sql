{%- for filter in filter_list %}
    {%- if filter is not mapping %}
        and {{ filter }}
    {%- elif filter.operator|upper == 'CONTAINS' %}
        and {{ filter.operator }}({{ filter.columnName }}, {{ filter.comparisonValue }})
    {%- else %}
        and {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
    {%- endif %}
{%- endfor %}
