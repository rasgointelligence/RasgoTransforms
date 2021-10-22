-- Args: {{bin_count}}, {{col_to_bin}}

SELECT *,
  width_bucket({{col_to_bin}},
      (SELECT MIN({{col_to_bin}}) FROM {{source_table}}),
      (SELECT MAX({{col_to_bin}}) FROM {{source_table}}),
      {{bin_count}}) AS {{col_to_bin}}_{{bin_count}}_EWB
FROM {{ source_table }}
