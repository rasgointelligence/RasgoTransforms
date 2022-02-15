{% if type == 'ntile' %}
SELECT *,
  ntile({{bin_count}}) OVER (ORDER BY {{column}}) AS {{column}}_{{bin_count}}_NTB
FROM {{ source_table }}
{% elif type == 'equalwidth' %}
SELECT *,
  width_bucket({{column}},
      (SELECT MIN({{column}}) FROM {{source_table}}),
      (SELECT MAX({{column}}) FROM {{source_table}}),
      {{bin_count}}) AS {{column}}_{{bin_count}}_EWB
FROM {{ source_table }}
{% else %}
{{ raise_exception('You must select either "ntile" or "equalwidth" as your binning type') }}
{% endif %}