with means as (
    select distinct {{column}} as value, ROUND(AVG({{target}}), 3) as mean_encode
    from {{ source_table }}
    group by value)

select t.*, m.mean_encode
from {{ source_table }} t
left join
means m
on t.{{column}} = m.value