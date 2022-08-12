{%- set distinct_val_query -%}
select distinct {{ value_column }}
from {{ source_table }}
limit 1000
{%- endset -%}

{%- set run_query_error_message -%}
This transform depends on dynamic values to work, but no Data Warehouse connection is available. 
Instead, please use the `list_of_vals` argument to provide these values explicitly
{%- endset -%}

{%- if list_of_vals is not defined -%}
{%- set results = run_query(distinct_val_query) -%}
{%- if results is none -%} {{ raise_exception(run_query_error_message) }} {%- endif -%}
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
            {{ dimensions | join(", ") }}{{ ',' if dimensions else '' }} {{ pivot_column }},
            {{ value_column }}
        from {{ source_table }}
    )
    pivot(
        {{ agg_method }} ({{ pivot_column }}) for {{ value_column }} in (
            '{{ distinct_vals | join("', '") }}'
        )
    ) as p
    (
        {{ dimensions | join(", ") }}{{ ',' if dimensions else '' }} {{ get_values(distinct_vals) }}
    )
