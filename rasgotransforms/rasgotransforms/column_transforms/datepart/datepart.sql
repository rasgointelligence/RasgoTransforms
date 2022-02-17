SELECT *,
{%- for target_col, date_part in dates.items() %}
  EXTRACT({{date_part}} FROM {{target_col}}) AS {{target_col}}_{{date_part}} {{ ", " if not loop.last else "" }}
{%- endfor %}
FROM {{ source_table }}