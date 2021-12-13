SELECT *,
{%- for target_col, date_part in dates.items() %}
    DATE({{target_col}}, '{{date_part}}') as {{target_col}}_date {{ ", " if not loop.last else "" }}
{%- endfor %}
from {{ source_table }}