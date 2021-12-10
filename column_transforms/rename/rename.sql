{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn=None) -%}
    {%- set database, schema, table = '', '', '' -%}
    {%- if source_table_fqtn -%}
        {%- set database, schema, table = source_table_fqtn.split('.') -%}
    {%- endif -%}
        SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
        WHERE TABLE_CATALOG = '{{ database|upper }}'
        AND   TABLE_SCHEMA = '{{ schema|upper }}'
        AND   TABLE_NAME = '{{ table|upper }}'
{%- endmacro -%}


{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}

{% if col_list|length != new_names|length %}
Rasgo Rename Error: The Column list must be the same length as the New Names list.
{% else %}
SELECT
{%- for target_col in col_list %}
    {{target_col}} AS {{new_names[loop.index-1]}}{{ ", " if not loop.last else "" }}
{% endfor %}
{%- for col in source_col_names %}
    {%- if col not in col_list %}, {{col}}{%- endif -%}
{% endfor %}
FROM {{ source_table }}

{% endif %}