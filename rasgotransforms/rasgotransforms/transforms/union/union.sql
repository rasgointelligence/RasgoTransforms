{# Get all Columns in Source Table #}
{%- set source_col_names = get_columns(source_table) -%}

{# Get all columns in Inputted Source #}
{%- set other_source_col_names = get_columns(dataset2) -%}

{# Get Unique Columns Across Both Datasets #}
{%- set union_cols = source_col_names.keys()|list + other_source_col_names.keys()|list -%}
{%- set union_cols = union_cols | unique | list -%}

{# Generate Union Query #}
select {{ union_cols | join(', ') }}
from {{ dataset2 }}
union
{{ 'ALL' if keep_dupes else '' }}
select {{ union_cols | join(', ') }}
from {{ source_table }}
