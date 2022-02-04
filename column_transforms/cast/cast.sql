SELECT *
{%- for target_col, type in casts.items() %}
    , CAST({{target_col}} AS {{type}}) AS {{cleanse_name(target_col)+'_'+cleanse_name(type)}}
{%- endfor %}
FROM {{ source_table }}