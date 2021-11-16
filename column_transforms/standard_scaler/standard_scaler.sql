with aggregates as (
  select avg({{column}}) as avg_dep,
  stddev({{column}}) as stddev_dep
  from {{source_table}})
select *, ({{column}} - avg_dep)
        / (stddev_dep) as {{column}}_scaled
from aggregates,{{source_table}}