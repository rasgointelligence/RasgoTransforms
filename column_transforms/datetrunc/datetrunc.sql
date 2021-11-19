{% set date_list = None %}
{%- if date_columns is string -%}
    {% set date_list = [date_columns] %}
{% else %}
    {% set date_list = date_columns %}
{%- endif -%}

SELECT *, 
{%- for col in date_list -%}
    DATE_TRUNC('{{date_part}}', {{col}}) as {{col}}_{{date_part}} {{ ", " if not loop.last else "" }}
{%- endfor -%}
from {{ source_table }}