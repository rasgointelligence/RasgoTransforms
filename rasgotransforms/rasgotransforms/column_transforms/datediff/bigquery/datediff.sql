SELECT *,
  DATE_DIFF({{ date_1 }}, {{ date_2 }}, {{ date_part }}) as {{ cleanse_name(date_2 + '_' + date_1 + '_datediff') }}
FROM {{ source_table }}