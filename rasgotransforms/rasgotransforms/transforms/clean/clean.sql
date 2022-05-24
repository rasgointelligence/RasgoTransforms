{%- set untouched_cols = get_columns(source_table)|list|reject('in', columns)|join(',')  + ', ' if not drop_columns else "" -%}

{%- set drop_cols = [] -%}
{%- for column in columns.keys() -%}
    {%- if columns[column].drop -%}
        {{drop_cols.append(column) or ""}}
    {%- endif -%}
{%- endfor -%}
{%- for col in drop_cols -%}
    {%- set _x = columns.pop(col) -%}
{%- endfor -%}

{%- macro get_select_column(name, col) -%}
    {%- set source_col = 'cast(' + name + ' as ' + col.type + ')'  if col.type is defined else name-%}
    {% set output_col_name = name if col.name is not defined else cleanse_name(col.name) %}
    {%- set impute_expression = '' -%}
    {%- if col.impute is not defined -%}
        {%- set output = source_col -%}
    {%- else -%}
        {%- if col.impute | lower in  ['mean', 'median', 'mode', 'max', 'min', 'sum', 'avg'] -%}
            {%- set impute = 'avg' if col.impute == 'mean' else col.impute -%}
            {%- set impute_expression = impute + '(' + source_col + ') over ()' -%}
        {%- else -%}
            {%- set impute_expression = "'" + col.impute + "'" if col.impute is string else col.impute|string -%}
        {%- endif -%}
        {%- set output = 'coalesce(' + source_col + ', ' + impute_expression + ')' -%}
    {%- endif -%}
    {{ output }} as {{ output_col_name }}
{%- endmacro -%}

{%- macro get_filter_statement(columns) -%}
    {%- set filter_statements = [] -%}
    {%- for column in columns.keys() %}
        {%- set output_col_name = column if columns[column].name is not defined else cleanse_name(columns[column].name) -%}
        {%- if columns[column].filter is defined -%}
            {{ filter_statements.append(output_col_name + ' ' + columns[column].filter) or ""}}
        {%- endif -%}
    {%- endfor -%}
    {%- for filter_statement in filter_statements -%}
        {{ "where " if loop.first else "" }}{{ filter_statement }}{{ " \n    and " if not loop.last else "" }}
    {%- endfor %}
{%- endmacro -%}
{%- set filter_statement = get_filter_statement(columns) -%}

{%- if filter_statement == "" -%}
select {{ untouched_cols }}
{%- for column in columns.keys() %}
  {{ get_select_column(column, columns[column]) }}{{ ", " if not loop.last else "" }}
{%- endfor %}
from {{ source_table }}

{%- else -%}
with cleaned as (
    select {{ untouched_cols }}
    {%- for column in columns.keys() %}
        {{ get_select_column(column, columns[column]) }}{{ ", " if not loop.last else "" }}
    {%- endfor %}
    from {{ source_table }}
) select * from cleaned
{{ filter_statement }}
{%- endif -%}
