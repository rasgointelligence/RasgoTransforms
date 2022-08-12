select
    *
    {% for col, aggs in aggregations.items() -%}
    {%- for agg in aggs %}
    ,
    {{ agg }} ({{ col }}) over (
        {%- if group_by %}partition by {{ group_by | join(", ") }} {% endif -%}
        order by {{ order_by | join(", ") }}
        {% if direction and direction.lower() == 'forward' -%}
        rows between current row and unbounded following
        {% else -%} rows between unbounded preceding and current row
        {%- endif -%}
    ) as {{ cleanse_name(agg + '_' + col) }}
    {%- endfor -%}
    {%- endfor %}
from {{ source_table }}
