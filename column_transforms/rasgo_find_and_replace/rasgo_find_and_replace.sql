{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn) -%}
    {%- set database, schema, table = '', '', '' -%}
    {%- set database, schema, table = source_table_fqtn.split('.') -%}
    SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
    WHERE TABLE_CATALOG = '{{ database }}'
    AND   TABLE_SCHEMA = '{{ schema }}'
    AND   TABLE_NAME = '{{ table }}'
{%- endmacro -%}

{%- macro quote_if_string(val) -%}
    {{ "'" + val + "'" if val is string else val }}
{%- endmacro -%}

{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}

{# Preset vars used below #}
{%- set find_val, replace_val = [None, None] -%}

SELECT
{%- for col in source_col_names %}
    {%- if col in replace_dict %}
    CASE
        {% for replacement_pair in replace_dict[col] -%}
            {%- set find_val, replace_val = replacement_pair -%}
        WHEN {{ col }} = {{ quote_if_string(find_val) }} THEN {{ quote_if_string(replace_val) }}
        {% endfor -%}
        ELSE {{ col }}
    END as {{ col }}{{ ',' if not loop.last else '' }}
    {%- else %}
    {{ col }}{{ ',' if not loop.last else '' }}
    {%- endif -%}
{% endfor %}
FROM {{ source_table }}