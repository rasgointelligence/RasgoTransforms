{%- set untouched_cols = get_columns(source_table)|list|reject('in', concat_list)|join(',') if overwrite_columns else "*" -%}

{%- set alias = cleanse_name(alias) if alias is defined else 'CONCAT_' ~ cleanse_name(concat_list | join('_')) -%}
select
    {{ untouched_cols }},
    concat(
        {%- for obj in concat_list %}
        {{ obj }}{{ ", " if not loop.last else "" }}
        {%- endfor %}
    ) as {{ alias }}
from {{ source_table }}
