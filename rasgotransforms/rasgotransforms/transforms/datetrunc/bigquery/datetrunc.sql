select
    *,
    {%- for target_col, date_part in dates.items() %}
    date_trunc(
        {{ target_col }}, {{ date_part }}
    ) as {{ target_col }}_{{ date_part }} {{ ", " if not loop.last else "" }}
    {%- endfor %}
from {{ source_table }}
