{%- if averages is not defined -%}
with
{%- for column in columns_to_scale %}
  agg_{{column}} as (
  select avg({{column}}) as avg_{{column}},
  stddev({{column}}) as stddev_{{column}}
  from {{source_table}}){{ ", " if not loop.last else "" }}
{% endfor -%}

select {{source_table}}.*,
{%- for column in columns_to_scale %}
({{column}} - avg_{{column}}) / (stddev_{{column}}) as {{column}}_standard_scaled{{ ", " if not loop.last else "" }}
{% endfor -%}
FROM
{% for column in columns_to_scale -%}
agg_{{column}},
{%- endfor -%}
{{source_table}}

{%- else -%}
select *,
{%- for column in columns_to_scale %}
({{column}} - {{averages[loop.index0]}}) / ({{standarddevs[loop.index0]}}) as {{column}}_standard_scaled{{ ", " if not loop.last else "" }}
{% endfor -%}
FROM {{source_table}}
{%- endif -%}