{%- if overwrite_columns == true -%}

{%- set source_columns = get_columns(source_table) -%}
{%- set untouched_cols = source_columns | reject('in', casts) -%}

select
    {% for col in untouched_cols %} {{ col }},{% endfor %}
    {%- for target_col, type in casts.items() %}
    cast(
        {{ target_col }} as {{ type }}
    ) as {{ target_col }}{{ ", " if not loop.last else "" }}
    {%- endfor %}
from {{ source_table }}

{%- else -%}

select
    *
    {%- for target_col, type in casts.items() %}
    ,
    cast(
        {{ target_col }} as {{ type }}
    ) as {{ cleanse_name(target_col)+'_'+cleanse_name(type) }}
    {%- endfor %}
from {{ source_table }}

{%- endif -%}
