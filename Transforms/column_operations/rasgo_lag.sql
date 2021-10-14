-- args: {{Columns}}, {{Amounts}}, {{Partition}}, {{OrderBy}}

SELECT
    {%- for col in Columns -%}
        {%- for amount in Amounts -%}
            lag({{col}}, {{amount}}) over (partition by {{Partition}} order by {{OrderBy}}) as Lag_{{col}}_{{amount}},
        {%- endfor -%}
    {%- endfor -%}
    *
from {{ source_table }}