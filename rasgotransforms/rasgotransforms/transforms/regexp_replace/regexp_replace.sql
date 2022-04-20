{% if position is not defined %}
{% set position = 1 %}
{% endif %}

{% if occurrence is not defined %}
{% set occurrence = 0 %}
{% endif %}

{% if parameters is not defined %}
{% set parameters = 'c' %}
{% endif %}

SELECT *,
REGEXP_REPLACE({{ source_col }}, '{{ pattern }}', '{{ replacement }}', {{ position }}, {{ occurrence }}, '{{ parameters }}') AS {{target_col if target_col is defined else "REGEXP_REPLACE_" + source_col}}
FROM {{ source_table }}