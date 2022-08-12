select
    *
    {% if end_pos %}
    ,
    substr(
        {{ target_col }}, {{ start_pos }}, {{ end_pos }}
    ) as substring_{{ cleanse_name(target_col) }}_{{ start_pos }}_{{ end_pos }}
    {% else %}
    ,
    substr(
        {{ target_col }}, {{ start_pos }}
    ) as substring_{{ cleanse_name(target_col) }}_{{ start_pos }}
    {% endif %}
from {{ source_table }}
