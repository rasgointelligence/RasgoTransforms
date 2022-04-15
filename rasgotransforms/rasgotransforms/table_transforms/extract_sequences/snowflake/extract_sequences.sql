WITH CTE_{{ column }} AS (
select * from {{ source_table }}
  match_recognize(
    partition by {{ group_by | join(', ') }}
    order by {{ order_by }}
    measures
      match_number() as SEQUENCE_NUMBER,
      first({{ order_by }}) as SEQUENCE_START_DATE,
      last({{ order_by }})  as SEQUENCE_END_DATE,
      count(*)              as SEQUENCE_LEN,
      count(row_decrease.*) as SEQUENCE_DECREASE_CNT,
      count(row_increase.*) as SEQUENCE_INCREASE_CNT
    one row per match
    after match skip to last row_increase
    pattern(FOO row_decrease+ row_increase+)
    define 
    row_decrease AS {{ column }} < lag({{ column }}),
    row_increase AS {{ column }} > lag({{ column }})
  )
)
SELECT * FROM CTE_{{ column }} ORDER BY {{ group_by | join(', ') }}, SEQUENCE_NUMBER