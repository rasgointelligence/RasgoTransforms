SELECT * FROM {{ source_table }}
UNPIVOT( {{ value_column }} for {{ name_column }} in ( {{ column_list | join(', ')}} ))
