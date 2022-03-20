{%- if quantity|float < 1 -%}
    {%- set sample_amount = quantity*100 |float -%}
{% else %}
    {%- set sample_amount = quantity~' ROWS' -%}
{% endif %}

SELECT * FROM {{source_table}}
sample row ( {{ sample_amount }} )