SELECT *,
{% for col in date_columns %}DATE({{col}}, '{{format_expression if format_expression is defined else 'YYYY-MM-DD'}}') as {{col}}_todate {{ ", " if not loop.last else "" }}{% endfor %}
from {{ source_table }}