{%- if overwrite_columns -%}
{%- set alias = date -%}
{%- set untouched_cols = get_columns(source_table)|list|reject('in', [alias])|join(',') -%}
{%- else -%} {%- set untouched_cols = "*" -%}
{%- endif -%}

{%- set alias = alias if alias is defined else date + '_add' + offset|string + date_part -%}

select
    {{ untouched_cols }},
    {{ date }} + interval '{{ offset }} {{ date_part }}' as {{ cleanse_name(alias) }}
from {{ source_table }}
