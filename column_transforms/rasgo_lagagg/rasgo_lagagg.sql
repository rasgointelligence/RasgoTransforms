SELECT *, 
    {% for col in columns %}
        {%- for window in windows -%}
            {{ agg_type }}(CASE WHEN {{date}} - {{event_date}} > 0 and {{date}} - {{event_date}} < {{window}} THEN {{col}}) as {{col}}_{{agg_type}}_{{window}}{{ ", " if not loop.last else "" }}
        {%- endfor -%}
        {{ ", " if not loop.last else "" }}
    {% endfor %}
from {{ source_table }} a
left join
{{rasgo_source_ref(event_dataset)}} b
on a.ID = b.ID