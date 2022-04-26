{%- if partition is not defined or partition|length == 0 -%}
{%- set partition = ["NULL"]-%}
{%- endif -%}
{%- if order_by is not defined or order_by|length == 0 -%}
{%- set order_by = ["NULL"]-%}
{%- endif -%}
SELECT *,
    {%- for col in columns -%}
        {%- for amount in amounts %}
        lag({{col}}, {{amount}}) over (partition by {{partition | join(", ")}} order by {{order_by | join(", ")}}) as Lag_{{ cleanse_name(col ~ '_' ~ amount) }}{{ "," if not loop.last else "" }}
        {%- endfor -%}
        {{ ", " if not loop.last else "" }}
    {%- endfor %}
from {{ source_table }}