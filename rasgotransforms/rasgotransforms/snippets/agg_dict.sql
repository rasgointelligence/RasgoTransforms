{%- for col, aggs in agg_dict.items() %}
    {%- set outer_loop = loop -%}
    {%- for agg in aggs %}
        {%- if ' DISTINCT' in agg|upper %}
            {{ agg|upper|replace(" DISTINCT", "") }}(DISTINCT {{ col }}) as {{ col ~ '_' ~ agg|upper|replace(" DISTINCT", "") ~ 'DISTINCT'}}{{ '' if loop.last and outer_loop.last else ',' }}
        {%- else %}
            {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
        {%- endif %}
    {%- endfor -%}
{%- endfor %}