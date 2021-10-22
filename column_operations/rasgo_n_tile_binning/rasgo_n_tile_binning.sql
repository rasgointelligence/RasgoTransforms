-- Args: {{bin_count}}, {{col_to_bin}}

SELECT *,
  ntile({{bin_count}}) OVER (ORDER BY {{col_to_bin}}) AS {{col_to_bin}}_{{bin_count}}_NTB
FROM {{ source_table }}
