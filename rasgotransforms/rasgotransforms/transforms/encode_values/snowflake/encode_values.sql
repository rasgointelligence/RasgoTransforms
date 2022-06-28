{% set untouched_cols = get_columns(source_table)|list|reject('in', [column]) if overwrite_columns else ['*'] %}
{% set alias = column if overwrite_columns else column + '_ENCODED' %}

{%- if method|lower == 'label' -%}

with distinct_values as (
    select 
        array_agg(distinct {{ column }}) within group (order by {{ column }} asc) as ALL_VALUES_ARRAY 
    from {{ source_table }}
)
select {{ untouched_cols|join(',') }},
    ALL_VALUES_ARRAY,
    array_position({{ column }}::variant,ALL_VALUES_ARRAY) as {{ alias }}
from distinct_values, {{ source_table }}

{%- elif method|lower == 'target' -%}

{%- if target is not defined -%}
{{ raise_exception("The 'target' parameter must be defined when using the target encoding method") }}
{%- endif -%}
with means as (
    select 
        distinct {{column}} as value, 
        ROUND(AVG({{target}}), 3) as {{alias}}
    from {{ source_table }}
    group by value
)
select 
    {% if overwrite_columns -%} 
    {%- for col in untouched_cols -%}
    t.{{col}},
    {%- endfor %}
    {% else -%}
    t.*,
    {%- endif -%}
    m.{{alias}}
from {{ source_table }} t
left join
    means m on t.{{column}} = m.value

{%- elif method|lower == 'oh' -%}

{%- set distinct_col_vals =  run_query("SELECT DISTINCT " +  column + " FROM " + source_table)[column].to_list() -%}
SELECT {{ untouched_cols|join(',') }},
{%- for val in distinct_col_vals %}
    {%- if val is not none %}
    CASE WHEN {{ column }} = {{ "'" ~ val ~ "'"}} THEN 1 ELSE 0 END as {{ cleanse_name(column ~ '_' ~ val) }}{{ ', ' if not loop.last else '' }}
    {%- else %}
    CASE WHEN {{ column }} IS NULL THEN 1 ELSE 0 END as {{ column }}_IS_NULL{{ ', ' if not loop.last else '' }}
    {%- endif -%}
{% endfor %}
FROM {{ source_table }}

{%- else -%}
{{ raise_exception("Method '" + method + "' is not recognized. Accepted encoding methods are 'label', 'target', and 'oh'")}}
{%- endif -%}