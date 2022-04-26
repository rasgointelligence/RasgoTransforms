{#
Jinja Macro to generate a query that would get all
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn=None) -%}
    select * from {{ source_table_fqtn }} limit 0
{%- endmacro -%}
{%- if subset is not defined -%}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set subset = col_names_source_df.columns.to_list() -%}
{%- set source_col_names = subset -%}
{%- endif -%}

{%- if how is not defined -%}
{%- set how = "any" -%}
{%- endif -%}

{%- if how == "any" and thresh is not defined -%}
select * from {{ source_table }}
{%- for col in subset %}
{{ 'where' if loop.first else 'and' }} {{ col }} is not null
{%- endfor -%}

{%- else -%}
{%- if thresh is not defined -%}
{%- set thresh = subset|length -%}
{%- endif -%}
{%- if source_col_names is not defined -%}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df.columns.to_list() -%}
{%- endif -%}
with not_null as (
    select *,
        {%- for col in subset %}
        cast({{ col }} is null as int) {{ "+ " if not loop.last else " " }}
        {%- endfor %}
        as NUM_IS_NA
    from {{ source_table }}
    where NUM_IS_NA < {{ thresh }}
) select
    {% for col in source_col_names -%}
    {{ col }}{{ ", " if not loop.last else " " }}
    {%- endfor %}
from not_null
{%- endif -%}