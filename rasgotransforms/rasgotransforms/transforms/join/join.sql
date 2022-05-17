{# Jinja Macro to get the table name from source_id #}
{%- macro get_table_name(join_table) -%}
    {%- set table = join_table.split('.')[-1] -%}
    {{ table }}
{%- endmacro -%}

{# Get all Columns in Source Table #}
{%- set source_col_names = get_columns(source_table) -%}

{# Get all Columns and Table Name in Join Table #}
{%- set join_col_names = get_columns(join_table) -%}
{%- set join_table_name = get_table_name(join_table) -%}


SELECT
{%- for source_col in source_col_names %}
  t1.{{ source_col }}{{ ', ' if not loop.last else '' }}
{%- endfor -%}
{%- for join_col in join_col_names %}
    {%- if join_prefix -%}
        , t2.{{ join_col }} as {{ cleanse_name(join_prefix)~'_'~join_col }}
    {%- elif join_col not in source_col_names -%}
        , t2.{{ join_col }}
    {% endif %}
{%- endfor %}
FROM {{ source_table }} as t1
{{ join_type + ' ' if join_type else '' | upper }}JOIN {{ join_table }} as t2
{%- for t1_join_col, t2_join_col in join_columns.items() %}
{{ ' AND' if not loop.first else 'ON'}} t1.{{ t1_join_col }} = t2.{{ t2_join_col }}
{%- endfor -%}
{%- if filters is defined and filters %}
    {% for filter_block in filters %}
        {%- set oloop = loop -%}
        {{ 'WHERE ' if oloop.first else ' AND ' }}
            {%- if filter_block is not mapping -%}
                {{ filter_block }}
            {%- else -%}
                {%- if filter_block['operator'] == 'CONTAINS' -%}
                    {{ filter_block['operator'] }}({{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }})
                {%- else -%}
                    {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
                {%- endif -%}
            {%- endif -%}
    {%- endfor -%}
{%- endif -%}