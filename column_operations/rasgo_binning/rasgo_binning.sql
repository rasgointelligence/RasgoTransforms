{% if binning_type == 'ntile' %}
SELECT *,
  ntile({{bin_count}}) OVER (ORDER BY {{col_to_bin}}) AS {{col_to_bin}}_{{bin_count}}_NTB
FROM {{ source_table }}
{% elif binning_type == 'equalwidth' %}
SELECT *,
  width_bucket({{col_to_bin}},
      (SELECT MIN({{col_to_bin}}) FROM {{source_table}}),
      (SELECT MAX({{col_to_bin}}) FROM {{source_table}}),
      {{bin_count}}) AS {{col_to_bin}}_{{bin_count}}_EWB
FROM {{ source_table }}
{% else %}
Rasgo binning error: You must select either "ntile" or "equalwidth" as your binning type
{% endif %}
