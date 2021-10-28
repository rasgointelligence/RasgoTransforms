SELECT * FROM {{source_table}}
{%- macro quote_if_string(var) -%}
    {%- set quote = "'" if var is string else '' -%}
    {{ quote }}{{ var }}{{ quote }}
{%- endmacro -%}

{%- for filter_statement in filter_statements %}
{{ 'WHERE' if loop.first else 'AND' }} {{ filter_statement }}
{%- endfor -%}