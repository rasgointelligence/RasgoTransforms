SELECT {% for group_item in group_by %}
{{ group_item }}, 
{%- endfor %}
{%- for k, vals in aggregations.items() -%}
   {%- set outer_loop = loop -%}
      {%- for v in vals -%}
      {%- if agg_key=='metric' -%}
          {%- set agg = k -%}
          {%- set col = v -%}
      {%- else -%}
          {%- set agg = v -%}
          {%- set col = k -%}
      {%- endif %}
{{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
    {%- endfor -%}
{% endfor %}
 FROM {{ source_table }}
 GROUP BY {{ group_by | join(', ') }}
