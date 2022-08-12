{%- for class, n in sample.items() %}
select *
from
    (
        select *
        from {{ source_table }}
        where {{ sample_col }} = '{{ class }}'
    ) sample({{ n }}{{ ' rows' if n > 1 else '' }}
    )
    {{ '' if loop.last else ' UNION ALL ' }}
{%- endfor %}
