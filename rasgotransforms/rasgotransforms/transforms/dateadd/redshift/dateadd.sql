{%- if overwrite_columns -%}
{%- set alias = date -%}
{%- set untouched_cols = get_untouched_columns(source_table, [alias]) -%}
{%- else -%}
{%- set untouched_cols = "*" -%}
{%- endif -%}

{%- set alias = alias if alias is defined else date + '_add' + offset|string + date_part -%}

SELECT {{ untouched_cols }},
  {{ date }} + INTERVAL '{{ offset }} {{ date_part }}' AS {{ cleanse_name(alias) }}
FROM {{ source_table }}