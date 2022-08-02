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
    {%- if agg_method|lower == "median" %}
        {{ raise_exception('BigQuery does not support median aggregation while pivoting.') }}
    {%- else %}
        {{ agg_method }} ( {{ pivot_column }} ) as _
    {%- endif %}
    FOR {{ value_column }} IN ( 
        {%- for val in distinct_vals %}
        {%- if val is string -%}
            '{{ val }}' {{ cleanse_name(val) }}
        {%- elif val is none -%}
            NULL NULL_REC
        {%- else -%}
            {{ val }} {{ cleanse_name(val) }}
        {%- endif -%}
            {{', ' if not loop.last else ''}}
        {%- endfor -%}
     )
)