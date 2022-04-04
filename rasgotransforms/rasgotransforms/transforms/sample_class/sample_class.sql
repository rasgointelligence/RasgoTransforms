{%- for class, n in sample.items() %}
    SELECT * FROM 
    (SELECT * FROM {{ source_table }} WHERE {{ sample_col }} = '{{ class }}') SAMPLE ({{ n }}{{' rows' if n > 1 else ''}})
    {{ '' if loop.last else ' UNION ALL ' }}
{%- endfor %}