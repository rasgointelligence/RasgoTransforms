{%- if overwrite_columns -%}
{%- set untouched_cols = get_untouched_columns(source_table, concat_list) -%}
{%- else -%}
{%- set untouched_cols = "*" -%}
{%- endif -%}

{%- set alias = cleanse_name(alias) if alias is defined else 'CONCAT_' ~ cleanse_name(concat_list | join('_')) -%}


SELECT {{ untouched_cols }},
    CONCAT(
        {%- for obj in concat_list %}
        {{obj}}{{ ", " if not loop.last else "" }}
        {%- endfor %}
    ) AS {{ alias }}
FROM {{ source_table }}