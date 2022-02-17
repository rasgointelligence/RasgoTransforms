SELECT *,
  DATEDIFF({{ date_part }}, {{ date_1 }}, {{ date_2 }}) as {{ cleanse_name(date_2 + '_' + date_1 + '_datediff') }}
FROM {{ source_table }}
