{% if include_cols and exclude_cols is defined %}
{{ raise_exception('You cannot pass both an include_cols list and an exclude_cols list') }}
{% else %}

{%- if exclude_cols is defined -%}
{%- set source_col_names = get_columns(source_table) -%}

{# Upper exclude cols to ensure case insensitive name matching #}
{%- set exclude_cols = (exclude_cols|join(',')|upper).split(',') -%}
{% set include_cols = [] -%}
{% for column_name in source_col_names -%}
    {% if column_name.upper() not in exclude_cols -%}
         {% do include_cols.append(column_name) -%}
    {% endif -%}
{% endfor -%}
{%- endif -%}

{%- if include_cols is defined -%}
SELECT
{%- for col in include_cols %}
    {{col}}{{ ", " if not loop.last else " " }}
{%- endfor %}
FROM {{source_table}}
{%- endif -%}

{%- endif -%}