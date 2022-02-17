SELECT *,
  DATE_ADD({{ date }}, INTERVAL {{ offset }} {{ date_part }}) AS {{ cleanse_name(date + 'add' + offset|string + date_part) }}
FROM {{ source_table }}