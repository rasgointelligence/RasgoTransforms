{% if col_list|length != type_list|length %}
Rasgo Cast Error: The Column list must be the same length as the Type list.
{% else %}
SELECT
*
{%- for target_col in col_list %}
    , TRY_CAST({{target_col}} AS {{type_list[loop.index-1]}}) AS {{cleanse_name(target_col)+'_'+cleanse_name(type_list[loop.index-1])}}
{%- endfor %}
FROM {{ source_table }}

{% endif %}
