{# Jinja Macro to get the table name from fqtn #}
{%- macro get_table_name(fqtn) -%}
    {%- set database, schema, table = fqtn.split('.') -%}
    {{ table }}
{%- endmacro -%}

{# Jinja Macro to get columns for a table #}
{%- macro get_column_names(fqtn) -%}
    {%- set database, schema, table = fqtn.split('.') -%}
    SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
    WHERE TABLE_CATALOG = '{{ database|upper }}'
    AND   TABLE_SCHEMA = '{{ schema|upper }}'
    AND   TABLE_NAME = '{{ table|upper }}'
{%- endmacro -%}

SELECT
t0.*
{% for fqtn in join_tables -%}
{%- set o_loop = loop -%}
{%- set table_only = get_table_name(fqtn=fqtn) -%}
{%- set col_names_df = run_query(get_column_names(fqtn=fqtn)) -%}
{%- set col_names = col_names_df['COLUMN_NAME'].to_list() -%}
    {% for column in col_names %}
, t{{o_loop.index}}.{{column}} as {{table_only}}_{{column}}
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