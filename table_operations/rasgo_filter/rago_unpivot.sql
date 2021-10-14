-- args: {{ value_column }}, {{ name_column }}, {{ column_list_vals }}

{%- set column_list_vals = [] -%}
{%- for col in column_list  -%}
    {{- column_list_vals.append('"' + col + '"')  or '' -}}
{%- endfor -%}
SELECT * FROM {{ source_table }}
unpivot( {{ value_column }} for {{ name_column }} in ( {{ column_list_vals | join(', ')}} ))