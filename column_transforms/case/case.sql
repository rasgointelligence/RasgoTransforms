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

{# Jinja Macro to single quote a value if a sting #}
{%- macro quote_if_string(val, col_names) -%}
    {%- if not val -%}
    {{ "NULL" }}
    {% elif val in col_names %}
    {{ val }}
    {% elif val is string %}
    {{ "'" + val + "'" }}
    {% else %}
    {{ val }}
    {%- endif -%}
{%- endmacro -%}

{#
Jinja Macro to create a WHEN statement in find and replace considering Nulls
#}
{%- macro make_when_statement(col, find_val, replace_val, source_col_names) -%}
    {%- if find_val -%}
    WHEN {{ col }} = {{ quote_if_string(find_val, source_col_names) }} THEN {{ quote_if_string(replace_val) }}
    {%- else -%}
    WHEN {{ col }} IS NULL THEN {{ quote_if_string(replace_val) }}
    {%- endif -%}
{%- endmacro -%}

{# Get Source Col Names #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}

{# Set up external objects #}
{%- set else_val = namespace(value=None) -%}

{# Preset vars used below #}
{%- set find_val, replace_val = [None, None] -%}

SELECT
{%- for col in source_col_names %}
    {%- if col in replace_dict %}
    {%- set output_col_name = namespace(value=col+"_REPLACED") -%}
    CASE
    {% for replacement_pair in replace_dict[col] -%}
    {%- if replacement_pair is string -%}
    {%- set output_col_name.value = replacement_pair -%}
    {%- elif replacement_pair|length == 2 -%}
    {%- set find_val, replace_val = replacement_pair -%}
    {{ make_when_statement(col, find_val, replace_val, source_col_names) }}
    {% elif replacement_pair|length == 1 %}
    {%- set else_val.value = replacement_pair[0] -%}
    {% else %}
    Rasgo Value Error: Each replacement pair must either be 1 item (for the default value), or a pair of items (for a find-replace)
    {%- endif -%}
    {% endfor -%}
    ELSE {{ quote_if_string(else_val.value, source_col_names) }}
    END AS {{ cleanse_name(output_col_name.value) }}{{ ',' if not loop.last else '' }}
    {{ col }}{{ ',' if not loop.last else '' }}
    {%- else %}
    {{ col }}{{ ',' if not loop.last else '' }}
    {%- endif -%}
{% endfor %}
FROM {{ source_table }}
