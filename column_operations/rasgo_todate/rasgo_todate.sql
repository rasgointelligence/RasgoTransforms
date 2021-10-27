SELECT *,
{% for col in date_columns %}TO_DATE({{col}}, '{{format_expression}}') as {{col}}_todate {{ ", " if not loop.last else "" }}{% endfor %}
from {{ source_table }}