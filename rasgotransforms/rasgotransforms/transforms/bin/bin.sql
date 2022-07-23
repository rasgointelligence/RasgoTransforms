SELECT *,
{% if type == 'ntile' %}
  ntile({{bin_count}}) OVER (ORDER BY {{column}}) AS {{column}}_{{bin_count}}_NTB
{% elif type == 'equalwidth' %}
  width_bucket({{column}},
      (SELECT MIN({{column}}) FROM {{source_table}}),
      (SELECT MAX({{column}}) FROM {{source_table}}),
      {{bin_count}}) AS {{column}}_{{bin_count}}_EWB
{% else %}
  {{ raise_exception('You must select either "ntile" or "equalwidth" as your binning type') }}
{% endif %}
FROM {{ source_table }}
