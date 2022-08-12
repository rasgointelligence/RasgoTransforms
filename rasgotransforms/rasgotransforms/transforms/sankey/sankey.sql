{%- for i in range((stage|length) - 1) -%}
select
    '{{ stage[i] }}_' || cast({{ stage[i] }} as string) as source_node,
    '{{ stage[i+1] }}_' || cast({{ stage[i+1] }} as string) as dest_node,
    count(*) as width
from {{ source_table }}
group by source_node, dest_node
having
    source_node is not null and dest_node is not null
    {{ "UNION ALL" if not loop.last else "" }}
{% endfor %}
