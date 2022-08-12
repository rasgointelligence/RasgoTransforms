{%- if alias is defined -%} {%- set alias = cleanse_name(alias) -%}
{%- else -%} {%- set alias = 'DIFF_'~ cleanse_name(date_1~'_'~date_2) -%}
{%- endif -%}

select *, date_diff({{ date_1 }}, {{ date_2 }}, {{ date_part }}) as {{ alias }}
from {{ source_table }}
