select *
from
    {{ source_table }}
    unpivot(
        {{ value_column }} for {{ name_column }} in ({{ column_list | join(', ') }})
    )
