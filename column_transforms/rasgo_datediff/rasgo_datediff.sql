SELECT *,
DATEDIFF({{ date_part }}, {{ date_val_1 }}, {{ date_val_2 }}) as {{ cleanse_name(date_val_2 + '_' + date_val_1  + '_' + date_part + '_datediff') }}
FROM {{ source_table }}
