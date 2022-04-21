{% if position is not defined %}
    {% set position = 1 %}
{% else %}
    {% set use_regex = True %}
{% endif %}

{% if occurrence is not defined %}
    {% set occurrence = 0 %}
{% else %}
    {% set use_regex = True %}
{% endif %}

{% if parameters is not defined %}
    {% set parameters = 'c' %}
{% else %}
    {% set use_regex = True %}
{% endif %}

{% if use_regex %}
SELECT *,
REGEXP_REPLACE({{ source_col }}, '{{ pattern }}', '{{ replacement }}', {{ position }}, {{ occurrence }}, '{{ parameters }}') AS {{cleanse_name(alias) if alias is defined else "REPLACE_" + source_col}}
FROM {{ source_table }}
{% else %}
SELECT *,
REPLACE({{ source_col }}, '{{ pattern }}', '{{ replacement }}') AS {{cleanse_name(alias) if alias is defined else "REPLACE_" + source_col}}
FROM {{ source_table }}
{% endif %}