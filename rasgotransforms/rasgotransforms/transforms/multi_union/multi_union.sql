{# Jinja Macro to get the table name from fqtn #}
{%- macro get_table_name(fqtn) -%}
    {%- set table = fqtn.split('.')[-1] -%}
    {{ table }}
{%- endmacro -%}

{%- set table_only = get_table_name(fqtn=source_table) -%}

SELECT '{{table_only}}' as origin_table, {{union_columns | join(", ")}}
FROM {{ source_table }}

{% for fqtn in union_tables -%}
{%- set table_name = get_table_name(fqtn=fqtn) -%}
UNION ALL

SELECT '{{table_name}}' as origin_table, {{union_columns | join(", ")}}
FROM {{ fqtn }}
{% endfor %}