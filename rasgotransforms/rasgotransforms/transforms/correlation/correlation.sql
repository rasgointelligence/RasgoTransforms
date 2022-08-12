{%- set names_types_list = get_columns(source_table) -%}

{%- set column_list = [] -%}

{%- for key, value in names_types_list.items() -%}
{% if (value|upper == 'NUMBER' or 'FLOAT' in value|upper or 'INT' in value|upper) %}
{%- do column_list.append(key) -%}
{%- endif -%}
{%- endfor -%}

with
    source_sampled as (
        select *
        from
            {{ source_table }}
            {% if rows_to_sample is defined %}
            sample({{ rows_to_sample }} rows)
            {% endif -%}
    )

select *
from
    (
        {%- for combo in itertools.product(column_list, repeat=2) -%}
        select
            '{{ combo[0] }}' as column_a,
            '{{ combo[1] }}' as column_b,
            corr({{ combo[0] }}, {{ combo[1] }}) as correlation
        from source_sampled
        {% if not loop.last %}
        union
        {% endif -%}
        {%- endfor -%}
    )
order by column_a, column_b
