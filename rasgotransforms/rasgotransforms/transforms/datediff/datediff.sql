{%- if alias is defined -%}
    {%- set alias = cleanse_name(alias) -%}
{%- else -%}
    {%- set alias = 'DIFF_'~ cleanse_name(date_1~'_'~date_2) -%}
{%- endif -%}

SELECT *,
  EXTRACT({{ date_part }} FROM DATE {{ date_1 }} - DATE {{ date_2 }}) AS {{ alias }}
FROM {{ source_table }}