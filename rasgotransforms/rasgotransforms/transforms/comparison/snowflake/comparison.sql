{% from 'filter.sql' import get_filter_statement %}

{%- if comparison_dimensions is defined and comparison_dimensions|length -%}
    {%- set dims = comparison_dimensions|join(', ') ~ ', '  -%}
{%- else -%}
    {%- set dims = '' -%}
{%- endif -%}

WITH filtered as (
    SELECT * 
    FROM {{ source_table }}
    {%- if shared_filters is defined %}
    WHERE 
    {{ get_filter_statement(shared_filters) | indent }}
    {%- endif %}
),
group_a as (
SELECT
    {{ dims }}
    {%- for column, aggs in comparison_values.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
            {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}{{ column }}) as {{ cleanse_name('Group_A_' ~ column ~ '_' ~ aggregation_type )}}{{ ',' if not (loop.last and oloop.last) }}
        {%- endfor %}
    {%- endfor %}
    FROM filtered
    {%- if group_a_filters is defined %}
    WHERE  
    {{ get_filter_statement(group_a_filters) | indent }}
    {%- endif %}
    {%- if comparison_dimensions is defined and comparison_dimensions|length %}
    GROUP BY {{ comparison_dimensions | join(', ') }}
    {%- endif %}
),
group_b as (
SELECT
    {{ dims }}
    {%- for column, aggs in comparison_values.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
            {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}{{ column }}) as {{ cleanse_name('Group_B_' ~ column ~ '_' ~ aggregation_type )}}{{ ',' if not (loop.last and oloop.last) }}
        {%- endfor %}
    {%- endfor %}
    FROM filtered
    {%- if group_b_filters is defined %}
    WHERE 
    {{ get_filter_statement(group_b_filters) | indent }}
    {%- endif %}
    {%- if comparison_dimensions is defined and comparison_dimensions|length %}
    GROUP BY {{ comparison_dimensions | join(', ') }}
    {%- endif %}
)

SELECT * 
FROM 
{%- if comparison_dimensions is defined and comparison_dimensions|length %}
group_a FULL OUTER JOIN group_b
USING ({{ comparison_dimensions | join(', ') }}) 
ORDER BY {{ comparison_dimensions | join(' DESC, ') }}  
NULLS LAST
{%- else %}
group_a CROSS JOIN group_b
{%- endif %}