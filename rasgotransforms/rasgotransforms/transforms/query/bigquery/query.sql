with
    base_table as (
        select
            *
            {%- for formula in new_columns %}
            , {{ formula }} as {{ cleanse_name(formula) }}
            {%- endfor %}
        from {{ source_table }}
    ),
    filtered as (
        select *
        from
            base_table
            {%- for filter in filters %}
            {{ " WHERE " if loop.first else "" }}
            {%- if filter is not mapping %} {{ filter }}
            {%- elif filter.operator|upper == 'CONTAINS' %}
            {{ filter.operator }} (
                {{ filter.columnName }}, {{ filter.comparisonValue }}
            )
            {%- else %}
            {{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
            {%- endif %}
            {{ " AND " if not loop.last else "" }}
            {%- endfor %}
    )
{%- if summarize is defined -%}
    ,
    aggregated as (
        select
            {%- if group_by is defined %} {{ group_by | join(', ') }}, {%- endif %}
            {%- for column, aggs in summarize.items() %}
            {%- set oloop = loop %}
            {%- for aggregation_type in aggs %}
            {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }} (
                {{ 'distinct ' if 'distinct' in aggregation_type|lower else '' }}{{ column }}
            )
            as {{ cleanse_name(aggregation_type + '_' + column) }}{{ ',' if not (loop.last and oloop.last) }}
            {%- endfor %}
            {%- endfor %}
        from filtered
        {%- if group_by is defined %} group by {{ group_by | join(', ') }} {%- endif %}
    )
select *
from aggregated
{% else %} select * from filtered
{%- endif -%}
{%- if order_by_columns is defined %}
order by {{ order_by_columns | join(', ') }} {{ order_by_direction }}
{%- endif -%}
