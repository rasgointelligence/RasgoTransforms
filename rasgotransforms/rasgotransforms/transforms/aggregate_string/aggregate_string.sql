select
    {{ group_by | join(', ') }}
    {%- for agg_column in agg_columns %}
    ,
    listagg(
        {{ 'distinct ' if distinct else '' }} {{ agg_column }}, '{{sep}}'
    ) within group (order by {{ agg_column }} {{ order }}) as {{ agg_column }}_listagg
    {%- endfor %}
from {{ source_table }}
group by {{ group_by | join(', ') }}
