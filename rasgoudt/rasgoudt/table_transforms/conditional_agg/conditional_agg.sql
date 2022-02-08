{%- if distinct -%}
    {%- set agg_thing = 'DISTINCT '~agg_column -%}
{%- else -%}
    {%- set agg_thing = agg_column -%}
{%- endif -%}
{%- set rule_combos = [] -%}
{%- for r in rules -%}
    {%- if loop.first -%}
        {%- set rule_combos = rule_combos.append(r) -%}
    {%- else -%}
        {%- set new_rule = rule_combos[loop.index-2] ~ ' AND ' ~ r -%}
        {%- set rule_combos = rule_combos.append(new_rule) -%}
    {%- endif -%}
{%- endfor -%}
{%- for rule in rule_combos -%}
SELECT '{{ rule|replace("'","") }}' AS rule_desc, {{ agg }}({{ agg_thing }}) as QTY 
FROM {{ source_table }} 
WHERE {{ rule }}
{% if not loop.last %}
UNION ALL
{% endif %}
{%- endfor -%}