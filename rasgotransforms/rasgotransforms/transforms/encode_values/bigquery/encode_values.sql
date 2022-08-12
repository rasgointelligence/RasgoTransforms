{% set untouched_cols = get_columns(source_table)|list|reject('in', [column]) if overwrite_columns else ['*'] %}
{% set alias = column if overwrite_columns else column + '_ENCODED' %}

{%- if method|lower == 'label' -%}

with
    distinct_values as (
        select distinct rank() over (order by {{ column }} asc) as id, {{ column }}
        from {{ source_table }}
        order by {{ column }} asc
    )
select
    {% if overwrite_columns -%}
    {%- for col in untouched_cols -%} t.{{ col }}, {%- endfor -%}
    {% else -%} t.*,
    {%- endif %}
    (v.id - 1) as {{ alias }}
from {{ source_table }} t
left join distinct_values v using ({{ column }})

{%- elif method|lower == 'target' -%}

{%- if target is not defined -%}
{{ raise_exception("The 'target' parameter must be defined when using the target encoding method") }}
{%- endif -%}
with
    means as (
        select distinct
            {{ column }} as value, round(avg({{ target }}), 3) as {{ alias }}
        from {{ source_table }}
        group by value
    )
select
    {% if overwrite_columns -%}
    {%- for col in untouched_cols -%} t.{{ col }}, {%- endfor %}
    {% else -%} t.*,
    {%- endif -%}
    m.{{ alias }}
from {{ source_table }} t
left join means m on t.{{ column }} = m.value

{%- elif method|lower == 'oh' -%}

{%- set distinct_col_vals =  run_query("SELECT DISTINCT " +  column + " FROM " + source_table)[column].to_list() -%}
select
    {{ untouched_cols|join(',') }},
    {%- for val in distinct_col_vals %}
    {%- if val is not none %}
    case
        when {{ column }} = {{ "'" ~ val ~ "'" }} then 1 else 0
    end as {{ cleanse_name(column ~ '_' ~ val) }}{{ ', ' if not loop.last else '' }}
    {%- else %}
    case
        when {{ column }} is null then 1 else 0
    end as {{ column }}_is_null{{ ', ' if not loop.last else '' }}
    {%- endif -%}
    {% endfor %}
from {{ source_table }}

{%- else -%}
{{ raise_exception("Method '" + method + "' is not recognized. Accepted encoding methods are 'label', 'target', and 'oh'") }}
{%- endif -%}
