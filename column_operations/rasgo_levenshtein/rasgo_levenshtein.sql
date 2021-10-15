-- args: {{Columns}}

-- should probably replace this batch slicer with a macro that creates all possible pairwise combinations from 'Columns'
-- this would be something we would use on any pairwise comparison functions

SELECT *,
{%- for ColumnPair in Columns|batch(2)|list %}
    {%- for cols in ColumnPair -%}
        EDITDISTANCE({{cols[0]}}, {{cols[1]}}) as {{cols[0]}}_{{cols[1]}}_Distance {{ ", " if not loop.last else "" }}
    {%- endfor -%}
{%- endfor -%}

FROM {{source_table}}