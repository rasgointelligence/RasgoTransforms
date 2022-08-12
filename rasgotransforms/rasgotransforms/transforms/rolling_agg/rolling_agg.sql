select
    *
    {% for col, aggs in aggregations.items() -%}
    {%- for agg in aggs -%}
    {%- for offset in offsets %}
    {% set normalized_offset = -offset %},
    {{ agg }} ({{ col }}) over (
        {%- if group_by %}partition by {{ group_by | join(", ") }} {% endif -%}
        order by {{ order_by | join(", ") }}
        {% if normalized_offset > 0 -%}
        rows between current row and {{ normalized_offset }} following
        {% else -%} rows between {{ normalized_offset|abs }} preceding and current row
        {% endif -%}
    ) as {{ cleanse_name(agg + '_' + col + '_' + offset|string) }}
    {%- endfor -%}
    {%- endfor -%}
    {%- endfor %}
from {{ source_table }}
