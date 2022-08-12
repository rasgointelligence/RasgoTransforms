{% if position is not defined %} {% set position = 1 %}
{% else %} {% set use_regex = True %}
{% endif %}

{% if occurrence is not defined %} {% set occurrence = 0 %}
{% else %} {% set use_regex = True %}
{% endif %}

{% if parameters is not defined %} {% set parameters = 'c' %}
{% else %} {% set use_regex = True %}
{% endif %}

{% if use_regex %}
select
    *,
    regexp_replace(
        {{ source_col }},
        '{{ pattern }}',
        '{{ replacement }}',
        {{ position }},
        {{ occurrence }},
        '{{ parameters }}'
    ) as {{ cleanse_name(alias) if alias is defined else "REPLACE_" + source_col }}
from {{ source_table }}
{% else %}
select
    *,
    replace(
        {{ source_col }}, '{{ pattern }}', '{{ replacement }}'
    ) as {{ cleanse_name(alias) if alias is defined else "REPLACE_" + source_col }}
from {{ source_table }}
{% endif %}
