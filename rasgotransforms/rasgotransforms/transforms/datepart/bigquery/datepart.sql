select
    *,
    {%- for target_col, date_part in dates.items() %}
    {%- if date_part|lower == 'weekiso' %}
    extract(
        isoweek from {{ target_col }}
    ) as {{ target_col }}_isoweek {{ ", " if not loop.last else "" }}
    {%- elif date_part|lower == 'dayofweekiso' %}
    mod(extract(dayofweek from {{ target_col }}) + 5, 7)
    + 1 as {{ target_col }}_isodayofweek {{ ", " if not loop.last else "" }}
    {%- elif date_part|lower == 'yearofweekiso' %}
    extract(
        isoyear from {{ target_col }}
    ) as {{ target_col }}_isoyear {{ ", " if not loop.last else "" }}
    {%- elif date_part|lower == 'yearofweek' %}
    extract(
        year from {{ target_col }}
    ) as {{ target_col }}_year {{ ", " if not loop.last else "" }}
    {%- else %}
    extract(
        {{ date_part }} from {{ target_col }}
    ) as {{ target_col }}_{{ date_part }} {{ ", " if not loop.last else "" }}
    {%- endif %}
    {%- endfor %}
from {{ source_table }}
