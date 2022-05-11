{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn=None) -%}
    select * from {{ source_table_fqtn }} limit 0
{%- endmacro -%}

{#
Get three things in this loop
    1. The column names 
    2. Mapping of fqtn -> table_name for all tables/FQTNs passed in
#}
{%- set table_col_names = [
    [
        'source_table',
        run_query(get_source_col_names(source_table_fqtn=source_table)).columns.to_list()
        
    ]
] 
-%}
{%- set table_name_mapping = {
    "source_table": source_table.split('.')[-1]
    }
-%}
{%- for join_dict in join_dicts -%}
    {%- set _x = table_col_names.append([
        join_dict['join_table'],
        run_query(get_source_col_names(source_table_fqtn=join_dict['join_table'])).columns.to_list()
        ])
    -%}
    {%- set _x = table_name_mapping.__setitem__(
        join_dict["join_table"], join_dict["join_table"].split('.')[-1]
        ) 
    -%}
{%- endfor -%}

{#
For each table joining, figure out the columns which need to be prefixed
#}
{%- set cols_to_prefix_mapping = {} -%}
{%- for join_table, join_table_cols in table_col_names[1:] -%}
    {%- set cols_to_prefix = [] -%}
    {%- set cols_to_check_for_overlap = [] -%}
    {%- for i in range(0, loop.index) -%}
        {%- set _x = cols_to_check_for_overlap.extend(table_col_names[i][1]) -%}
    {%- endfor %}
    {%- for join_col in join_table_cols -%}
        {%- if join_table_col in cols_to_check_for_overlap -%}
            {%- set _x = cols_to_prefix.append(join_table_col) -%}
        {%- endif -%}
    {%- endfor -%}
    {%- set _x = cols_to_prefix_mapping.__setitem__(join_table, cols_to_prefix) -%}
    {%- set cols_to_check_for_overlap = cols_to_check_for_overlap + join_table_cols -%}
{%- endfor -%}

{#
Macro for getting the column selection

This includes adding prefixes if we marked that column as needing a prefix
#}
{%- macro get_columns_to_select_in_query() -%}
    {# First get the column selections for the source table #}
    {%- set source_fqtn, source_col_names = table_col_names[0] -%}
    {%- for source_col_name in source_col_names -%}
        {{ table_name_mapping[source_fqtn] }}'.'{{ source_col_name }},
    {% endfor -%}
    {# Next get the column selections for the join tables #}
{%- endmacro -%}


{{get_columns_to_select_in_query()}}

{{source_table}}