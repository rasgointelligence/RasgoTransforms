SELECT *, 
    {%- for col in columns1 -%}
    {%- for col2 in columns2 %}
    EDITDISTANCE({{col}}, {{col2}}) as {{col}}_{{col2}}_Distance{{ ", " if not loop.last else "" }}
    {%- endfor -%}{{ ", " if not loop.last else "" }}
    {%- endfor %}
FROM {{source_table}}