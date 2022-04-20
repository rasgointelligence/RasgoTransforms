SELECT *,
REPLACE({{ source_col }}, '{{ pattern }}', '{{ replacement }}') AS {{target_col if target_col is defined else "REPLACE_" + source_col}}
FROM {{ source_table }}

