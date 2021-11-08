SELECT *,
DATEDIFF({{ date_part }}, {{ date_col_1 }}, {{ date_col_2 }}) as {{ date_col_2 }}_{{ date_col_1 }}_{{ date_part }}_datediff
FROM {{ source_table }}
