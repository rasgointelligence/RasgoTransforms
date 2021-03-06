{%- if overwrite_columns -%}
{%- set alias = date -%}
{%- set untouched_cols = get_columns(source_table)|list|reject('in', [alias])|join(',') -%}
{%- else -%}
{%- set untouched_cols = "*" -%}
{%- endif -%}

{%- set alias = alias if alias is defined else date + '_add' + offset|string + date_part -%}

SELECT {{ untouched_cols }},
  {{ date }} + INTERVAL {{ offset }} {{ date_part }} AS {{ cleanse_name(alias) }}
FROM {{ source_table }}