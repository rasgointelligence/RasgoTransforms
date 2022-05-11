{%- set names_types_list = get_columns(source_table) -%}

{%- set column_list = [] -%}

{%- for key, value in names_types_list.items() -%}
    {% if (value|upper == 'NUMBER' or 'FLOAT' in value|upper or 'INT' in value|upper) %}
    {%- do column_list.append(key) -%}
    {%- endif -%}
{%- endfor -%}

SELECT * FROM (
{%- for combo in itertools.product(column_list, repeat=2) -%}
    SELECT '{{ combo[0] }}' as COLUMN_A,
    '{{ combo[1] }}' as COLUMN_B,
    CORR({{ combo[0] }}, {{ combo[1] }}) as Correlation
    FROM {{ source_table }}
    {% if not loop.last %} UNION {% endif -%}
{%- endfor -%}
)
ORDER BY COLUMN_A, COLUMN_B