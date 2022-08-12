select
    *,
    {%- if order_by is defined %}
    case
        when
            row_number() over (order by {{ order_by | join(", ") }}) < (
                count(1) over () * {{ train_percent }}
            )
        then 'TRAIN'
        else 'TEST'
    end as tt_split
    {%- else %}
    case
        when mod(random(), 1 /{{ train_percent }}) = 0 then 'TEST' else 'TRAIN'
    end as tt_split
    {%- endif %}
from {{ source_table }}
