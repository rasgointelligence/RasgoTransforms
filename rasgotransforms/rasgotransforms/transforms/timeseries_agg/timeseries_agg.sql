select
    *
    {% for offset in offsets %}
    {% set normalized_offset = -offset %}
    {% for col, aggs in aggregations.items() %}
    {% for agg in aggs %}
    ,
    (
        select {{ agg }} ({{ col }})
        from {{ source_table }} i
        where
            {% if normalized_offset > 0 %}
            i.{{ date }} between o.{{ date }} and (
                o.{{ date }} + interval {{ normalized_offset }} {{ date_part }}
            )
            {% else %}
            i.{{ date }} between (
                o.{{ date }} - interval {{ normalized_offset|abs }} {{ date_part }}
            ) and o.{{ date }}
            {% endif %}
            {% for g in group_by %} and o.{{ g }} = i.{{ g }} {% endfor %}
    ) as {{ cleanse_name(agg + '_' + col + '_' + offset|string + date_part) }}
    {% endfor %}
    {% endfor %}
    {% endfor %}
from {{ source_table }} o
