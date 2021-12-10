{%- if minimums is not defined -%}
with
{%- for column in columns_to_scale %}
  agg_{{column}} as (
  select min({{column}}) as min_{{column}},
  max({{column}}) as max_{{column}}
  from {{source_table}}){{ ", " if not loop.last else "" }}
{% endfor -%}

select {{source_table}}.*,
{%- for column in columns_to_scale %}
({{column}} - min_{{column}}) / (max_{{column}} - min_{{column}}) as {{column}}_min_max_scaled{{ ", " if not loop.last else "" }}
{% endfor -%}
FROM
{% for column in columns_to_scale -%}
agg_{{column}},
{%- endfor -%}
{{source_table}}

{%- else -%}
select *,
{%- for column in columns_to_scale %}
({{column}} - {{minimums[loop.index0]}}) / ({{maximums[loop.index0]}} - {{minimums[loop.index0]}}) as {{column}}_min_max_scaled{{ ", " if not loop.last else "" }}
{% endfor -%}
FROM {{source_table}}
{%- endif -%}