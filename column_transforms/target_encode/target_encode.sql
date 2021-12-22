with means as (
    select distinct {{column}} as value, round(mean({{target}}, 3) as mean_encode
    group by value
)

select *, means.mean_encode
from {{ source_table }}
left join
means m
on {{source_table}}.{{column}} = means.value