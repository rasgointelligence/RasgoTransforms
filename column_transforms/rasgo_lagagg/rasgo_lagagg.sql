SELECT *, 
    {% for col in columns %}
        {%- for window in windows -%}
            {{ AGG_TYPE }}({CASE WHEN {{DATE}} - {{EVENT_DATE}} > 0 and {{DATE}} - {{EVENT_DATE}} < {{window}} THEN {{col}}) as {{col}}_{{AGG_TYPE}}_{{window}}{{ ", " if not loop.last else "" }}
        {%- endfor -%}
        {{ ", " if not loop.last else "" }}
    {% endfor %}
from {{ source_table }} a
left join
rasgo_source_ref({{EVENT_DATASET}}) b
on a.ID = b.ID