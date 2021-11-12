SELECT
*
{% if end_pos %}
    , SUBSTR({{ target_col }}, {{ start_pos }}, {{ end_pos }}) AS SUBSTRING_{{ cleanse_name(target_col) }}_{{ cleanse_name(start_pos) }}_{{ cleanse_name(end_pos) }}
{% else %}
    , SUBSTR({{ target_col }}, {{ start_pos }}) AS SUBSTRING_{{ cleanse_name(target_col) }}_{{ clenase_name(start_pos) }}
{% endif %}
FROM {{ source_table }}
