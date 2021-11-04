SELECT *, 
    {% for col in columns %}
        {%- for amount in amounts -%}
            lag({{col}}, {{amount}}) over (partition by {{partition | join(", ")}} order by {{order_by | join(", ")}}) as Lag_{{col}}_{{amount}}{{ ", " if not loop.last else "" }}
        {%- endfor -%}
        {{ ", " if not loop.last else "" }}
    {% endfor %}
from {{ source_table }}