SELECT *,
{%- for target_col, date_part in dates.items() %}
  DATE_TRUNC({{date_part}}, {{target_col}}) as {{target_col}}_{{date_part}} {{ ", " if not loop.last else "" }}
{%- endfor %}
FROM {{ source_table }}