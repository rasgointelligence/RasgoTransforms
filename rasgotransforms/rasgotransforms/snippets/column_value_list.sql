(
{% for val in column_value_list %}
    '{{ val }}'{{ ',' if not loop.last }}
{% endfor %}
)