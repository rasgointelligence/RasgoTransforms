{% set date_list = None %}
{%- if date_column is string -%}
    {% set date_list = [date_column] %}
{% else %}
    {% set date_list = date_column %}
{%- endif -%}

SELECT *, 
{%- for col in date_list -%}
    DATE_PART({{date_part}}, {{col}}) as {{col}}_datepart_{{date_part}} {{ ", " if not loop.last else "" }}
{%- endfor -%}
from {{ source_table }}