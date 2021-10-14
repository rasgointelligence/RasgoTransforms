-- Args: {{date_part}}, {{date_column}}
-- date_part: ['year','month','day','week','quarter','hour','minute','second','millisecond','microsecond']

{% set date_list = None %}
{%- if date_column is string -%}
    {% set date_list = [date_column] %}
{% else %}
    {% set date_list = date_column %}
{%- endif -%}

SELECT *, 
{%- for col in date_list -%}
    DATE_TRUNC({{date_part}}, {{col}}) as {{col}}_{{date_part}} {{ ", " if not loop.last else "" }}
{%- endfor -%}
from {{ source_table }}