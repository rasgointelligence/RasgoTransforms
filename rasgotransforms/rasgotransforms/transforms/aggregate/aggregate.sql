{%- set aggregations = aggregations.copy() %}
{%- if 'numeric columns' in aggregations.keys() and aggregations['numeric columns']|length > 0 %}
    {%- set all_columns = get_columns(source_table) %}
    {%- for column, column_type in all_columns.items() %}
        {%- if column not in aggregations.keys() and column_type|lower in ['int', 'integer', 'bigint', 'smallint', 'number', 'numeric', 'float', 'float4', 'float8', 'decimal', 'double precision', 'real'] %}
            {%- do aggregations.setdefault(column, []).extend(aggregations['numeric columns']) %}
        {%- endif %}
    {%- endfor %}
    {%- set _ = aggregations.pop('numeric columns') %}
{%- endif -%}

{%- if 'nonnumeric columns' in aggregations.keys() and aggregations['nonnumeric columns']|length > 0 %}
    {%- set all_columns = all_columns if all_columns is defined else get_columns(source_table) %}
    {%- for column, column_type in all_columns.items() %}
        {%- if column not in aggregations.keys() and column_type|lower not in ['int', 'integer', 'bigint', 'smallint', 'number', 'numeric', 'float', 'float4', 'float8', 'decimal', 'double precision', 'real'] %}
            {%- do aggregations.setdefault(column, []).extend(aggregations['nonnumeric columns']) %}
        {%- endif %}
    {%- endfor %}
    {%- set _ = aggregations.pop('nonnumeric columns') %}
{%- endif -%}

SELECT
{%- for group_item in group_by %}
    {{ group_item }},
{%- endfor -%}

{%- for col, aggs in aggregations.items() %}
    {%- set outer_loop = loop -%}
    {%- for agg in aggs %}
        {%- if ' DISTINCT' in agg|upper %}
            {{ agg|upper|replace(" DISTINCT", "") }}(DISTINCT {{ col }}) as {{ col ~ '_' ~ agg|upper|replace(" DISTINCT", "") ~ 'DISTINCT'}}{{ '' if loop.last and outer_loop.last else ',' }}
        {%- else %}
            {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
        {%- endif %}
    {%- endfor -%}
{%- endfor %}
FROM {{ source_table }}
GROUP BY {{ group_by | join(', ') }}
