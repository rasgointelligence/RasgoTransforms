{%- for amount in window_sizes -%}
{%- if amount < 0 -%}
{{ raise_exception('Cannot use negative values for a moving average. Please only pass positive values in `window_sizes`.') }}
{%- endif -%}
{%- endfor -%}
select
    *
    {%- for column in input_columns -%}
    {%- for window in window_sizes -%}
    ,
    avg({{ column }}) over (
        partition by {{ partition | join(", ") }}
        order by {{ order_by | join(", ") }}
        rows between {{ window - 1 }} preceding and current row
    ) as mean_{{ column }}_{{ window }}
    {%- endfor %}
    {%- endfor %}
from {{ source_table }}
