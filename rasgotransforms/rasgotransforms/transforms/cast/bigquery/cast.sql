{%- if overwrite_columns == true -%}

{%- set source_columns = get_columns(source_table) -%}
{%- set untouched_cols = source_columns | reject('in', casts) -%}

select
    {% for col in untouched_cols %} {{ col }},{% endfor %}
    {%- for target_col, type in casts.items() %}
    {%- if type|lower == 'float' %}
    cast(
        {{ target_col }} as float64
    ) as {{ target_col }}{{ ", " if not loop.last else "" }}f
    {%- elif type|lower == 'number' %}
    cast(
        {{ target_col }} as numeric
    ) as {{ target_col }}{{ ", " if not loop.last else "" }}
    {%- else %}
    cast(
        {{ target_col }} as {{ type }}
    ) as {{ target_col }}{{ ", " if not loop.last else "" }}
    {%- endif %}
    {%- endfor %}
from {{ source_table }}

{%- else -%}

select
    *
    {%- for target_col, type in casts.items() %}
    {%- if type|lower == 'float' %}
    ,
    cast(
        {{ target_col }} as float64
    ) as {{ cleanse_name(target_col)+'_'+cleanse_name(type) }}
    {%- elif type|lower == 'number' %}
    ,
    cast(
        {{ target_col }} as numeric
    ) as {{ cleanse_name(target_col)+'_'+cleanse_name(type) }}
    {%- else %}
    ,
    cast(
        {{ target_col }} as {{ type }}
    ) as {{ cleanse_name(target_col)+'_'+cleanse_name(type) }}
    {%- endif %}
    {%- endfor %}
from {{ source_table }}

{%- endif -%}
