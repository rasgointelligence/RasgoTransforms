{%- if alias is defined -%}
    {%- set alias = cleanse_name(alias) -%}
{%- else -%}
    {%- set alias = 'DIFF_'~ cleanse_name(date_1~'_'~date_2) -%}
{%- endif -%}

SELECT *,
  DATE_DIFF({{ date_1 }}, {{ date_2 }}, {{ date_part }}) as {{ alias }}
FROM {{ source_table }}