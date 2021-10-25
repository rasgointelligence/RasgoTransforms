select
  dateadd(
    '{{ interval_type }}',
      {{ interval_amount}} * row_number() over (order by null),
      {{ start_timestamp }}::timestamp_ntz)
  ) as ts_ntz
from table (generator(rowcount => {{ count }}));