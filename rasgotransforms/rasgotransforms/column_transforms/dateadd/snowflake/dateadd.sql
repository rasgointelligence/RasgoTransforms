SELECT *,
  DATEADD({{ date_part }}, {{ offset }}, {{ date }}) AS {{ cleanse_name(date + 'add' + offset|string + date_part) }}
FROM {{ source_table }}