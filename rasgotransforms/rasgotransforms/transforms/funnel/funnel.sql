{%- for col_name in stage_columns -%}
select '{{ col_name }}' as label, sum({{ col_name }}) as label_count
from {{ source_table }} {{ "UNION ALL" if not loop.last else "" }}
{% endfor %}
