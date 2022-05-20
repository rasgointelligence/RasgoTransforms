SELECT
*
{% if end_pos %}
    , SUBSTR({{ target_col }}, {{ start_pos }}, {{ end_pos }}) AS SUBSTRING_{{ cleanse_name(target_col) }}_{{ start_pos }}_{{ end_pos }}
{% else %}
    , SUBSTR({{ target_col }}, {{ start_pos }}) AS SUBSTRING_{{ cleanse_name(target_col) }}_{{ start_pos }}
{% endif %}
FROM {{ source_table }}
