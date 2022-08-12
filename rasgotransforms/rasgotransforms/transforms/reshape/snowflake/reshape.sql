{% if method|lower == 'pivot' -%}
    {%- set distinct_val_query -%}
    select distinct {{ columns }}
    from {{ source_table }}
    limit 1000
    {%- endset -%}

{%- if list_of_vals is not defined -%}
{%- set results = run_query(distinct_val_query) -%}
{%- set distinct_vals = results[results.columns[0]].to_list() -%}
{%- else -%} {%- set distinct_vals = list_of_vals -%}
{%- endif -%}

{# Jinja Macro to get the comma separated cleansed name list #}
{%- macro get_values(distinct_values) -%}
{%- for val in distinct_vals -%}
{{ cleanse_name(val) }}{{ ', ' if not loop.last else '' }}
{%- endfor -%}
{%- endmacro -%}


select
    {{ dimensions | join(", ") }}{{ ',' if dimensions else '' }} {{ get_values(distinct_vals) }}
from
    (
        select
            {{ dimensions | join(", ") }}{{ ',' if dimensions else '' }} {{ values }},
            {{ columns }}
        from {{ source_table }}
    )
    pivot(
        {{ agg_method }} ({{ values }}) for {{ columns }} in (
            '{{ distinct_vals | join("', '") }}'
        )
    ) as p
    (
        {{ dimensions | join(", ") }}{{ ',' if dimensions else '' }} {{ get_values(distinct_vals) }}
    )
{%- else -%}
select *
from
    {{ source_table }}
    unpivot({{ value_column }} for {{ name_column }} in ({{ columns | join(', ') }}))
{%- endif -%}
