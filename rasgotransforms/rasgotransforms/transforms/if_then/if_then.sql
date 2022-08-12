select
    *,
    case
        {%- for condition in conditions %}
        {{ "WHEN " + condition[0] }} then {{ condition[1] }}
        {% endfor %}
        else {{ default }}
    end as {{ cleanse_name(alias) }}
from {{ source_table }}
