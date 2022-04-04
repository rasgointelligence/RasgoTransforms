{# Jinja Macro to get columns for a table #}
{%- macro get_column_names(fqtn) -%}
    select * from {{ fqtn }} limit 0
{%- endmacro -%}


{%- if join_prefixes|length != join_tables|length -%}
{{ raise_exception('Provide a join_prefix for each join_table in the join_tables list') }}
{%- elif join_prefixes|length == join_tables|length -%}

SELECT
t0.*
{% for fqtn in join_tables -%}
{%- set table_alias = cleanse_name(join_prefixes[loop.index-1]) -%}
{%- set o_loop = loop -%}
{%- set col_names_df = run_query(get_column_names(fqtn=fqtn)) -%}
{%- set col_names = col_names_df.columns.to_list() -%}
    {% for column in col_names %}
, t{{o_loop.index}}.{{column}} as {{ table_alias~'_'~column }}
    {%- endfor %}
{%- endfor %}
FROM {{ source_table }} t0
{% for fqtn in join_tables -%}
{% set outer_loop = loop %}
{{ join_type + ' ' | upper }}JOIN
{{ fqtn }} t{{loop.index}}
    {%- for join_col in join_columns -%}
    {{' AND ' if not loop.first else ' ON '}} t0.{{ join_col }} = t{{ outer_loop.index }}.{{ join_col }}
    {% endfor -%}
{%- endfor -%}
{%- endif -%}