{%- set untouched_cols = get_columns(source_table)|list|reject('in', columns_to_scale)|join(',') if overwrite_columns else "*" -%}
{%- set method = method|lower if method is defined else 'standard' -%}

{%- if method == 'standard' -%}

{%- if averages is not defined or standarddevs is not defined -%}
with avg_stddev_vals as (
  select 
    {%- for column in columns_to_scale %}
    avg({{column}}) as avg_{{column}},
    stddev({{column}}) as stddev_{{column}}{{ ", " if not loop.last else "" }}
    {%- endfor %}
  from {{source_table}}
) select {{ source_table + ".*" if not overwrite_columns else untouched_cols}},
{%- for column in columns_to_scale %}
  ({{column}} - avg_{{column}}) / (stddev_{{column}}) as {{column if overwrite_columns else column + "_SCALED"}}{{ ", " if not loop.last else "" }}
{%- endfor %}
from avg_stddev_vals, {{source_table}}
{%- else -%}
select {{ untouched_cols }},
{%- for column in columns_to_scale %}
  ({{column}} - {{averages[loop.index0]}}) / ({{standarddevs[loop.index0]}}) as {{column if overwrite_columns else column + "_SCALED"}}{{ ", " if not loop.last else "" }}
{%- endfor %}
from {{source_table}}
{%- endif -%}

{%- elif method == 'min_max' -%}

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
  ({{column}} - min_{{column}}) / (max_{{column}} - min_{{column}}) as {{column if overwrite_columns else column + "_SCALED"}}{{ ", " if not loop.last else "" }}
{%- endfor %}
from min_max_vals, {{source_table}}

{%- else -%}
select {{ untouched_cols }},
{%- for column in columns_to_scale %}
  ({{column}} - {{minimums[loop.index0]}}) / ({{maximums[loop.index0]}} - {{minimums[loop.index0]}}) as {{column if overwrite_columns else column + "_SCALED"}}{{ ", " if not loop.last else "" }}
{%- endfor %}
from {{source_table}}
{%- endif -%}

{%- else -%}

{{ raise_exception("Method '" + method + "' is not recognized. The supported methods are 'standard' and 'min_max'.")}}

{%- endif -%}