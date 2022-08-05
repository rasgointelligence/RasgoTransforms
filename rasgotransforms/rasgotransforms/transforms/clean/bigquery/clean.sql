{%- set source_col_names = get_columns(source_table) -%}
{%- for column_name in source_col_names.keys() -%}
    {%- if column_name not in columns.keys() -%}
        {%- do columns.__setitem__(column_name, {}) -%}
    {%- endif  -%}
{%- endfor -%}
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
    {%- if col.type is defined -%}
        {%- if col.type|lower == 'float' -%}
            {%- set source_col = 'cast(' + name + ' as FLOAT64)' -%}
        {%- elif col.type|lower == 'number' -%}
            {%- set source_col = 'cast(' + name + ' as NUMERIC)' -%}
        {%- else -%}
            {%- set source_col = 'cast(' + name + ' as ' + col.type + ')' -%}
        {%- endif -%}
    {%- else -%}
        {%- set source_col = name -%}
    {%- endif -%}
    {% set output_col_name = name if col.name is not defined else cleanse_name(col.name) %}
    {%- set impute_expression = 'NULL' -%}
    {%- if col.impute is not defined -%}
        {%- set output = source_col -%}
    {%- else -%}
        {%- if col.impute | lower in  ['mean', 'mode', 'max', 'min', 'sum', 'avg', 'count'] -%}
            {%- set impute = 'avg' if col.impute|lower == 'mean' else col.impute -%}
            {%- set impute_expression = impute + '(' + source_col + ') over ()' -%}
        {%- elif col.impute|lower == 'count_distinct' -%}
            {%- set impute_expression = 'count(distinct ' + source_col + ') over ()' -%}
        {%- elif col.impute|lower == "median" -%}
            {%- if col.type is defined -%}
                {%- if col.type|lower == 'float' -%}
                    {%- set impute_expression = 'cast(PERCENTILE_CONT(' +  source_col + ', 0.5) over () as FLOAT64)' -%}
                {%- elif col.type|lower == 'number' -%}
                    {%- set impute_expression = 'cast(PERCENTILE_CONT(' +  source_col + ', 0.5) over () as NUMERIC)' -%}
                {%- else -%}
                    {%- set impute_expression = 'cast(PERCENTILE_CONT(' +  source_col + ', 0.5) over () as ' + col.type + ')' -%}
                {%- endif -%}
            {%- else -%}
                {%- set impute_expression = 'PERCENTILE_CONT(' +  source_col + ', 0.5) over ()' -%}
            {%- endif -%}
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
select
{%- for column in columns.keys() %}
  {{ get_select_column(column, columns[column]) }}{{ ", " if not loop.last else "" }}
{%- endfor %}
from {{ source_table }}

{%- else -%}
with cleaned as (
    select
    {%- for column in columns.keys() %}
        {{ get_select_column(column, columns[column]) }}{{ ", " if not loop.last else "" }}
    {%- endfor %}
    from {{ source_table }}
) select * from cleaned
{{ filter_statement }}
{%- endif -%}
