{% set date_list = None %}
{%- if date_column is string -%}
    {% set date_list = [date_column] %}
{% else %}
    {% set date_list = date_column %}
{%- endif -%}

SELECT *, 
{%- for col in date_list -%}
    TO_DATE({{col}}, '{{format_expression}}') as {{col}}_todate {{ ", " if not loop.last else "" }}
{%- endfor -%}
from {{ source_table }}