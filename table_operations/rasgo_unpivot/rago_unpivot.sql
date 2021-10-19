{#- args: {{ value_column} }, {{ name_column }} {{ column_list_vals }} -#}

SELECT * FROM {{ source_table }}
UNPIVOT( {{ value_column }} for {{ name_column }} in ( {{ '"' }}{{ column_list_vals | join('", "')}}{{ '"' }} ))