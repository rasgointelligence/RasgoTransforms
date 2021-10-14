-- args: {{dimensions}}, {{pivot_column}}, {{value_column}}, {{agg_method}}

{%- set get_distinct_vals -%}
    select distinct {{ value_column }}
    from {{ source_table }}
    limit 1000
{%- endset -%}
{%- set results = run_query(get_distinct_vals) -%}
{%- set distinct_vals = results[results.columns[0]].to_list() -%}

SELECT {{ dimensions }}, {{ distinct_vals | join(", ") }}
FROM ( SELECT {{ dimensions }}, {{ pivot_column }}, {{ value_column }} FROM {{ source_table }})
PIVOT ( {{ agg_method }} ( {{ pivot_column }} ) FOR {{ value_column }} IN ( '{{ distinct_vals | join("', '") }}' ) ) as p ( {{ dimensions }}, {{ distinct_vals | join(", ") }} )