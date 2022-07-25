SELECT *,
{%- for target_col, date_part in dates.items() %}
  {%- if date_part|lower == 'weekiso' %}
    EXTRACT(ISOWEEK FROM {{ target_col }}) AS {{ target_col }}_ISOWEEK {{ ", " if not loop.last else "" }}
  {%- elif date_part|lower == 'dayofweekiso' %}
    MOD(EXTRACT(DAYOFWEEK FROM {{ target_col }}) + 5, 7) + 1 AS {{ target_col }}_ISODAYOFWEEK {{ ", " if not loop.last else "" }}
  {%- elif date_part|lower == 'yearofweekiso' %}
    EXTRACT(ISOYEAR FROM {{ target_col }}) AS {{ target_col }}_ISOYEAR {{ ", " if not loop.last else "" }}
  {%- elif date_part|lower == 'yearofweek' %}
    EXTRACT(YEAR FROM {{ target_col }}) AS {{ target_col }}_YEAR {{ ", " if not loop.last else "" }}
  {%- else %}
    EXTRACT({{ date_part }} FROM {{ target_col }}) AS {{ target_col }}_{{ date_part }} {{ ", " if not loop.last else "" }}
  {%- endif %}
{%- endfor %}
FROM {{ source_table }}
