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

SELECT * FROM (
    SELECT
        {%- for dimension in dimensions %}
        {{ dimension }},
        {%- endfor %}
        {{ pivot_column }},
        {{ value_column }}
    FROM {{ source_table }}
)
PIVOT ( 
    {{ agg_method }} ( {{ pivot_column }} ) as _
    FOR {{ value_column }} IN ( 
        {%- for val in distinct_vals %}
        {%- if val is string -%}
        '{{ val }}'
        {%- else -%}
        {{ val }}
        {%- endif -%}
        {{', ' if not loop.last else ''}}
        {%- endfor -%}
     )
)