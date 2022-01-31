{%- if name is defined -%}
    {%- set alias = cleanse_name(name) -%}
{%- else -%}
    {%- set alias = 'CONCAT_'~ cleanse_name(concat_list | join('_')) -%}
{%- endif -%}

SELECT
*
, CONCAT(
    {%- for obj in concat_list %}
    {{obj}}{{ ", " if not loop.last else "" }}
    {%- endfor %}
) AS {{ alias }}
FROM {{ source_table }}