SELECT {{ group_by | join(', ') }}
{%- for agg_column in agg_columns %}
, listagg({{ 'distinct ' if distinct else ''}} {{agg_column}}, '{{sep}}')
WITHIN group (order by {{agg_column}} {{order}}) as {{agg_column}}_listagg
{%- endfor %}
FROM {{ source_table }}
GROUP BY {{ group_by | join(', ') }}