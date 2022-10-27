(
{% for option in custom_option_list %}
    '{{ option }}'{{ ',' if not loop.last }}
{% endfor %}
)