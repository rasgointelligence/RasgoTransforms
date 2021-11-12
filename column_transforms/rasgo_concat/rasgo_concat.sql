SELECT
*
, CONCAT(
    {%- for obj in concat_list %}
    {{obj}}{{ ", " if not loop.last else "" }}
    {%- endfor %}
) AS CONCAT_{%- for obj in concat_list %}{{cleanse_name(obj)}}{%- endfor %}
FROM {{ source_table }}
