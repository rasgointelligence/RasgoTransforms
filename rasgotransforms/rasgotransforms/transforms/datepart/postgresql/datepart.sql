select
    *,
    {%- for target_col, date_part in dates.items() %}
    date_part(
        '{{date_part}}', {{ target_col }}
    ) as {{ target_col }}_{{ date_part }} {{ ", " if not loop.last else "" }}
    {%- endfor %}
from {{ source_table }}
