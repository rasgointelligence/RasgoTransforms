{%- set distinct_val_query -%}
select distinct {{ value_column }}
from {{ source_table }}
limit 1000
{%- endset -%}

{%- if list_of_vals is not defined -%}
    {%- set results = run_query(distinct_val_query) -%}
    {%- set distinct_vals = results[results.columns[0]].to_list() -%}
{%- else -%}
    {%- set distinct_vals = list_of_vals -%}
{%- endif -%}


SELECT {{ dimensions | join(", ") }}, {{ distinct_vals | join(", ") }}
FROM ( SELECT {{ dimensions | join(", ") }}, {{ pivot_column }}, {{ value_column }} FROM {{ source_table }})
PIVOT ( {{ agg_method }} ( {{ pivot_column }} ) FOR {{ value_column }} IN ( '{{ distinct_vals | join("', '") }}' ) ) as p ( {{ dimensions | join(", ") }}, {{ distinct_vals | join(", ") }} )