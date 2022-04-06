with distinct_values as (    
  select distinct 
    rank() over(order by {{ column }} asc) as id,
    {{ column }})
  from {{ source_table }} 
  order by {{ column }} asc
)
select *,
  (v.id - 1) as {{ column }}_encoded
FROM {{ source_table }} t
left join distinct_values v using ({{ column }})