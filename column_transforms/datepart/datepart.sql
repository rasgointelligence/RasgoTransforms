SELECT *,
{% for col in date_columns %}DATE_PART('{{date_part}}', {{col}}) as {{col}}_datepart_{{date_part}} {{ ", " if not loop.last else "" }}{% endfor %}
from {{ source_table }}