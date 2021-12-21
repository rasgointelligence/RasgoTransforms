with distinct_values as (
    select array_agg(distinct {{ column }}) within group (order by {{ column }} asc) as all_values_array from {{ source_table }}
)
select *,
array_position({{ column }}::variant,all_values_array) as {{ column }}_encoded
from distinct_values,{{ source_table }}