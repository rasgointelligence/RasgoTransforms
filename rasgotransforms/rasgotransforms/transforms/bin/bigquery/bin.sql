SELECT *,
{%- if type == 'ntile' %}
  ntile({{bin_count}}) OVER (ORDER BY {{column}}) AS {{column}}_{{bin_count}}_NTB
{%- elif type == 'equalwidth' %}
  RANGE_BUCKET(
    {{ column }},
    GENERATE_ARRAY(
      (SELECT MIN({{ column }}) FROM {{ source_table }})
      ,(SELECT MAX({{ column }}) FROM {{ source_table }})
      ,(SELECT (MAX({{ column }}) - MIN({{ column }}))/20 FROM {{ source_table }})
    )
  ) AS {{column}}_{{bin_count}}_EWB
{%- else %}
  {{ raise_exception('You must select either "ntile" or "equalwidth" as your binning type') }}
{%- endif %}
FROM {{ source_table }}
