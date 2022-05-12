{%- if subset is not defined -%}
{%- set subset = get_columns(source_table) -%}
{%- set source_col_names = subset -%}
{%- endif -%}

{%- if how is not defined -%}
{%- set how = "any" -%}
{%- endif -%}

{%- if how == "any" and thresh is not defined -%}
select * from {{ source_table }}
{%- for col in subset %}
{{ 'where' if loop.first else '    and' }} {{ col }} is not null
{%- endfor -%}

{%- else -%}
{%- if thresh is not defined -%}
{%- set thresh = subset|length -%}
{%- endif -%}
{%- if source_col_names is not defined -%}
{%- set source_col_names = get_columns(source_table) -%}
{%- endif -%}
with not_null as (
    select *,
        {%- for col in subset %}
        cast({{ col }} is null as int) {{ "+ " if not loop.last else " " }}
        {%- endfor %}
        as NUM_IS_NA
    from {{ source_table }}
    where NUM_IS_NA < {{ thresh }}
) select
    {% for col in source_col_names -%}
    {{ col }}{{ ", " if not loop.last else " " }}
    {%- endfor %}
from not_null
{%- endif -%}