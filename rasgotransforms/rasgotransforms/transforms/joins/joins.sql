{#
Get two things in this loop
    1. The column names of each base table in the Join
    2. Mapping of fqtn -> table_name for all tables/FQTNs passed in
#}
{%- macro table_from_fqtn(fqtn) -%}
    {{ fqtn.split('.')[-1] }}
{%- endmacro -%}
{%- set source_col_names = [] -%}
{%- set source_get_columns_keys = get_columns(source_table).keys() -%}
{%- for col_name in source_get_columns_keys -%}
    {%- set _x = source_col_names.append(col_name) -%}
{%- endfor -%}
{# Init Dict/List of lists we actaully need to get; fill it initially with source_table #}
{%- set table_col_names = [['source_table', source_col_names]] -%}
{%- for join_dict in join_dicts -%}
    {%- set join_table_col_names = [] -%}
    {%- set join_table_get_columns_keys = get_columns(join_dict['table_b']).keys() -%}
    {%- for join_table_col_name in join_table_get_columns_keys -%}
        {%- set _x = join_table_col_names.append(join_table_col_name) -%}
    {%- endfor -%}
    {%- set _x = table_col_names.append([join_dict['table_b'], join_table_col_names]) -%}
{%- endfor -%}
{# For each table joining, figure out the columns which need to be prefixed #}
{%- set cols_to_prefix_mapping = {} -%}
{%- for join_table, join_table_cols in table_col_names[1:] -%}
    {%- set cols_to_prefix = [] -%}
    {%- set cols_to_check_for_overlap = [] -%}
    {%- for i in range(0, loop.index) -%}
        {%- set _x = cols_to_check_for_overlap.extend(table_col_names[i][1]) -%}
    {%- endfor %}
    {%- for join_table_col in join_table_cols -%}
        {%- if join_table_col in cols_to_check_for_overlap -%}
            {%- set _x = cols_to_prefix.append(join_table_col) -%}
        {%- endif -%}
    {%- endfor -%}
    {%- set _x = cols_to_prefix_mapping.__setitem__(join_table, cols_to_prefix) -%}
    {%- set cols_to_check_for_overlap = cols_to_check_for_overlap + join_table_cols -%}
{%- endfor -%}
{#
Macro for getting the column selection in full JOIN statement; This includes adding prefixes if we marked that column as needing a prefix
#}
{%- macro get_columns_to_select_in_query() -%}
    {# First get the column selections for the source table #}
    {%- set source_fqtn, source_col_names = table_col_names[0] -%}
    {%- for source_col_name in source_col_names %}
    {{ table_from_fqtn(source_table) }}.{{ source_col_name }},{% endfor -%}
    {# Next get the column selections for the join tables #}
    {%- for join_table, join_table_cols in table_col_names[1:] -%}
        {%- set outer_loop = loop -%}
        {%- set join_dict = join_dicts[loop.index0] -%}
        {%- for join_table_col in join_table_cols -%}
            {# Add prefix if we marked that column as needing a prefix #}
            {%- if join_table_col in cols_to_prefix_mapping[join_table] %}
    {{ table_from_fqtn(join_table) }}.{{ join_table_col }} as {{ join_dict["join_prefix_b"] }}__{{ join_table_col }}{{ " " if outer_loop.last and loop.last else "," }}
            {%- else %}
    {{ table_from_fqtn(join_table) }}.{{ join_table_col }}{{ " " if outer_loop.last and loop.last else "," }}
            {%- endif -%}
        {%- endfor -%}
    {%- endfor -%}
{%- endmacro -%}
{# Create the Final Join Statement #}
SELECT {{get_columns_to_select_in_query()}}
FROM {{ source_table }}
{% for join_dict in join_dicts -%}
{%- set outer_loop = loop -%}
{{ join_dict["join_type"] }} JOIN {{ join_dict["table_b"] }}
{% if join_dict["join_type"]|upper != 'CROSS' -%}
ON {%- for join_col1, join_col2 in join_dict["join_on"].items() -%}
{{ " AND " if loop.index != 1 else "" }}
{{ table_from_fqtn(source_table) if outer_loop.index == 1 else table_from_fqtn(join_dict["table_a"]) }}.{{ join_col1 }} = {{ table_from_fqtn(join_dict["table_b"]) }}.{{ join_col2 }}
{%- endfor %}
{%- endif -%}
{% endfor -%}
