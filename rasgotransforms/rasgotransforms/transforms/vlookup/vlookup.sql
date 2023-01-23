{%- macro table_from_fqtn(fqtn) -%}
    {{ fqtn.split('.')[-1] }}
{%- endmacro -%}

{# Get all Columns in Source Table #}
{%- set source_col_names = get_columns(source_table) -%}

{# Get relevant Columns and Table Name in Lookup Table #}
{%- if keep_columns is defined -%}
    {%- set lookup_table_cols = keep_columns -%}
{%- else -%}
    {%- set lookup_table_cols = get_columns(lookup_table) -%}
{%- endif -%}
{%- set lookup_table_name = table_from_fqtn(lookup_table) -%}


SELECT base.*, 
{%- for column in lookup_table_cols %}
    {%- if column in source_col_names -%}
        lookupt.{{ column }} as {{ lookup_table_name }}_{{ column }}{{ ', ' if not loop.last }}
    {%- else -%}
        {{ column }}{{ ', ' if not loop.last }}
    {%- endif -%}
{%- endfor %}
FROM {{ source_table }} base
LEFT OUTER JOIN {{ lookup_table }} lookupt
on base.{{ lookup_column }} = lookupt.{{ lookup_column }}
