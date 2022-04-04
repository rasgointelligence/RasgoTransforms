SELECT *,
{%- for target_col, date_format in dates.items() %}
    DATE({{target_col}}, '{{date_format}}') as {{target_col}}_date {{ ", " if not loop.last else "" }}
{%- endfor %}
from {{ source_table }}