{% if method|lower == 'pivot' -%}
    {%- set distinct_val_query -%}
    select distinct {{ columns }}
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
            {{ values }},
            {{ columns }}
        FROM {{ source_table }}
    )
    PIVOT ( 
        {{ agg_method }} ( {{ values }} ) as _
        FOR {{ columns }} IN ( 
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
{%- else -%}
    SELECT * FROM {{ source_table }}
    UNPIVOT( {{ value_column }} for {{ name_column }} in ( {{ columns | join(', ')}} ))
{%- endif -%}