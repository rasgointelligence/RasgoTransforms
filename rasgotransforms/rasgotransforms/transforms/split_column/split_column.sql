{%- set source_col_names = get_columns(source_table) -%}

with
    deliminated as (
        select
            *,
            {% for col in output_cols %}
            {%- if loop.first -%}
            case
                when charindex('{{ sep }}', {{ target_col }}) > 0
                then charindex('{{ sep }}', {{ target_col }})
                else len({{ target_col }}) + 1
            end as ix_{{ col }},
            {% elif not loop.last -%}
            case
                when
                    charindex('{{ sep }}', {{ target_col }}, ix_{{ loop.previtem }} + 1)
                    > 0
                then
                    charindex('{{ sep }}', {{ target_col }}, ix_{{ loop.previtem }} + 1)
                else len({{ target_col }}) + 1
            end as ix_{{ col }},
            {% else -%} len({{ target_col }}) + 1 as ix_{{ col }},
            {% endif -%}
            {%- endfor %}

            {%- for col in output_cols %}
            {%- if loop.first -%}
            case
                when ix_{{ col }} > 0
                then substring({{ target_col }}, 1, ix_{{ col }} - 1)
                else null
            end as {{ col }},
            {% else -%}
            case
                when ix_{{ col }} > ix_{{ loop.previtem }}
                then
                    substring(
                        {{ target_col }},
                        ix_{{ loop.previtem }} + 1,
                        ix_{{ col }} - ix_{{ loop.previtem }} - 1
                    )
                else null
            end as {{ col }}{{ ", " if not loop.last else " " }}
            {% endif -%}
            {%- endfor %}
        from {{ source_table }}
        limit 100
    )
select
    {% for col in source_col_names -%}
    {{ col }}
    {%- if col == target_col -%}
    {%- for output_col in output_cols -%}, {{ output_col }} {%- endfor -%}
    {%- endif -%}
    {{ ", " if not loop.last else " " }}
    {%- endfor %}
from deliminated
