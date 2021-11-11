SELECT
*
, CONCAT(
    {%- for obj in concat_list %}
    {{obj}}{{ ", " if not loop.last else "" }}
    {%- endfor %}
)
FROM {{ source_table }}
