{%- set untouched_cols = get_columns(source_table)|list|reject('in', dates)|join(',') if overwrite_columns else "*" -%}

SELECT {{ untouched_cols }},
{%- for target_col, date_format in dates.items() %}
    DATE({{target_col}}, '{{date_format}}') as {{target_col if overwrite_columns else target_col + "_DATE"}}{{ ", " if not loop.last else "" }}
{%- endfor %}
from {{ source_table }}