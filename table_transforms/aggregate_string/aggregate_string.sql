SELECT {{ group_by | join(', ') }},
listagg({{ 'distinct ' if distinct else ''}} {{agg_column}}, '{{sep}}')
WITHIN group (order by {{agg_column}} {{order}}) as {{agg_column}}_listagg
FROM {{ source_table }}
GROUP BY {{ group_by | join(', ') }}