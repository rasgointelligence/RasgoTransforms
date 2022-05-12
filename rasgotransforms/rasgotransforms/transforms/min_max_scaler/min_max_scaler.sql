{%- set untouched_cols = get_columns(source_table)|list|reject('in', columns_to_scale)|join(',') if overwrite_columns else "*" -%}

{%- if minimums is not defined -%}
with min_max_vals as (
  select
    {%- for column in columns_to_scale %}
    min({{column}}) as min_{{column}},
    max({{column}}) as max_{{column}}{{ "," if not loop.last else "" }}
    {%- endfor %}
  from {{source_table}}
) select {{ source_table + ".*" if not overwrite_columns else untouched_cols}},
{%- for column in columns_to_scale %}
  ({{column}} - min_{{column}}) / (max_{{column}} - min_{{column}}) as {{column if overwrite_columns else column + "_MIN_MAX_SCALED"}}{{ ", " if not loop.last else "" }}
{%- endfor %}
from min_max_vals, {{source_table}}

{%- else -%}
select {{ untouched_cols }},
{%- for column in columns_to_scale %}
  ({{column}} - {{minimums[loop.index0]}}) / ({{maximums[loop.index0]}} - {{minimums[loop.index0]}}) as {{column if overwrite_columns else column + "_MIN_MAX_SCALED"}}{{ ", " if not loop.last else "" }}
{%- endfor %}
from {{source_table}}
{%- endif -%}