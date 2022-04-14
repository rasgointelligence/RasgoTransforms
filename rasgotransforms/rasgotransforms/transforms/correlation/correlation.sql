{%- macro get_col_names_types(source_table_fqtn=None) -%}
    {%- set database, schema, table = source_table_fqtn.split('.') -%}
    SELECT COLUMN_NAME, DATA_TYPE
    FROM {{ database }}.information_schema.columns
    WHERE TABLE_CATALOG = '{{ database|upper }}'
    AND   TABLE_SCHEMA = '{{ schema|upper }}'
    AND   TABLE_NAME = '{{ table|upper }}'
{%- endmacro -%}
{# Get all Columns in Source Table #}
{%- set names_types_df = run_query(get_col_names_types(source_table_fqtn=source_table)) -%}
{%- set names_types_list = names_types_df.set_index('COLUMN_NAME')['DATA_TYPE'].to_dict() -%}

{%- set column_list = [] -%}

{%- for key, value in names_types_list.items() -%}
    {% if (value == 'NUMBER' or 'FLOAT' in value or 'INT' in value) %}
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