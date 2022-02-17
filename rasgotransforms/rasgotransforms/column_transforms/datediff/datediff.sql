SELECT *,
  EXTRACT({{ date_part }} FROM DATE {{ date_1 }} - DATE {{ date_2 }}) AS {{ cleanse_name(date_2 + '_' + date_1 + '_datediff') }}
FROM {{ source_table }}