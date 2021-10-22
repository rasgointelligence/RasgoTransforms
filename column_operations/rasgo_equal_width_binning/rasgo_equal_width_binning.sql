-- Args: {{bin_count}}, {{col_to_bin}}

SELECT *,
  width_bucket({{col_to_bin}}, MIN({{col_to_bin}}), MAX({{col_to_bin}}), {{bin_count}}) AS {{col_to_bin}}_{{bin_count}}_EWB
FROM {{ source_table }}
