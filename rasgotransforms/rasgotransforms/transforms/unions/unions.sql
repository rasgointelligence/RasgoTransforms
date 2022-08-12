{# Get all Columns in Source Table #}
{%- set source_col_names = get_columns(source_table) -%}
{% set ns = namespace(union_columns=source_col_names.keys()) %}

{%- for utable in union_tables -%}
{%- set utable_cols = get_columns(utable) -%}
{%- set ns.union_columns = ns.union_columns|list|select("in", utable_cols.keys()|list) -%}
{%- endfor -%}

{%- set columns_to_select = ns.union_columns|join(', ') -%}

{# Generate Union Query #}
select {{ columns_to_select }}
from {{ source_table }}
{%- for u_table in union_tables %}
union
{{ 'ALL' if not remove_duplicates else '' }}
select {{ columns_to_select }}
from {{ u_table }}
{%- endfor -%}
