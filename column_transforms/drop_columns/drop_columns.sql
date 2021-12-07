{#
Jinja Macro to generate a query that would get all 
the columns in a table by source_Id or fqtn
#}
{%- macro get_source_col_names(source_id=None, source_table_fqtn=None) -%}
    {%- set database, schema, table = '', '', '' -%}
    {%- if source_table_fqtn -%}
        {%- set database, schema, table = source_table_fqtn.split('.') -%}
    {%- else -%}
        {%- set database, schema, table = rasgo_source_ref(source_id).split('.') -%}
    {%- endif -%}
        SELECT COLUMN_NAME FROM {{ database }}.information_schema.columns
        WHERE TABLE_CATALOG = '{{ database|upper }}'
        AND   TABLE_SCHEMA = '{{ schema|upper }}'
        AND   TABLE_NAME = '{{ table|upper }}'
{%- endmacro -%}

{% if include_cols and exclude_cols is defined %}
Rasgo Error: You cannot pass both an include_cols list and an exclude_cols list
{% else %}

{%- if include_cols is defined -%}
SELECT 
{% for col in include_cols -%}
{{col}}{{ ", " if not loop.last else " " }}
{%- endfor %}
FROM {{source_table}}
{%- endif -%}

{%- if exclude_cols is defined -%}
{# Get all Columns in Source Table #}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df['COLUMN_NAME'].to_list() -%}

SELECT
{% for col in source_col_names -%}
{%- if col not in exclude_cols %}{{ ", " if not loop.first else "" }}{{col}}{%- endif -%}
{%- endfor %}
FROM {{source_table}}


{%- endif -%}

{% endif %}