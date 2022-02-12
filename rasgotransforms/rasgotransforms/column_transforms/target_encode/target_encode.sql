select t.*, m.{{column}}_target_encoded
from {{ source_table }} t
left join (
  select 
    distinct {{column}} as value, 
    ROUND(AVG({{target}}), 3) as {{column}}_target_encoded
  from {{ source_table }}
  group by value
) m
on t.{{column}} = m.value