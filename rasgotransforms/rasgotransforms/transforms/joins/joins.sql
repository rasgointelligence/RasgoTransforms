{%- macro table_from_fqtn(fqtn) -%}
    {{ fqtn.split('.')[-1] }}
{%- endmacro -%}

{# Create global variables to track query components #}
{%- set ns = namespace() -%}
{%- set ns.alias_columns=[] -%}
{%- set ns.select_columns='' -%}
{%- set ns.all_columns={} -%}
{%- set ns.all_tables=[] -%}
{%- set ns.columns_to_check = [] -%}

{# assemble lists of all columns and all tables in the query using a loop #}
{%- for join_dict in join_dicts -%}
    {%- if loop.index == 1 -%}
        {%- set base_table = source_table -%}
    {%- else -%}
        {%- set base_table = join_dict['table_a'] -%}
    {%- endif -%}
    {%- set jtable = join_dict['table_b'] -%}
    {# Check if base_table in the running list of all tables yet or not. If not, we need to add it and add its columns to all_columns. #}
    {%- if base_table not in ns.all_tables  -%}
        {%- set base_cols = get_columns(base_table) -%}
        {%- set x=ns.all_columns.__setitem__(base_table, base_cols.keys()|list) -%}
    {%- endif -%}
    {%- if jtable not in ns.all_tables  -%}
        {%- set jtable_cols = get_columns(jtable) -%}
        {%- set x=ns.all_columns.__setitem__(jtable, jtable_cols.keys()|list) -%}
    {%- endif -%}
    {%- set ns.all_tables = ns.all_tables + [base_table, jtable] -%}
{%- endfor -%}

{# loop through all columns in all tables to check for column names that are repeated between tables. These need to be aliased. #}
{%- for fqtn, columns in ns.all_columns.items() -%}
    {%- set ns.columns_to_check = [] -%}
    {%- for check_fqtn in ns.all_tables -%}
        {%- if fqtn != check_fqtn -%}
            {%- set ns.columns_to_check = ns.columns_to_check + ns.all_columns[check_fqtn] -%}
        {%- endif -%}
    {%- endfor -%}
    {%- set columns_to_alias = columns|select("in", ns.columns_to_check)|list -%}
    {%- set ns.alias_columns = ns.alias_columns + columns_to_alias -%}
{%- endfor -%}

{# assemble the SELECT clause by aliasing columns that need to be aliased and just using column name otherwise. #}
{%- for fqtn, columns in ns.all_columns.items() -%}
    {%- set o_loop = loop -%}
    {%- for column in columns -%}
    {%- set table_prefix = table_from_fqtn(fqtn) -%}
        {%- if column in ns.alias_columns -%}
            {%- set ns.select_columns = ns.select_columns ~ table_prefix ~ '.' ~ column ~ ' AS ' ~ table_prefix ~ '_' ~ column -%}
        {%- else -%}
            {%- set ns.select_columns = ns.select_columns ~ ' ' ~ column -%}
        {%- endif -%}
        {%- if not (loop.last and o_loop.last) -%}
            {%- set ns.select_columns = ns.select_columns ~ ', ' -%}
        {%- endif -%}
    {%- endfor -%}
{%- endfor -%}

{# assemble the full query #}
SELECT {{ ns.select_columns }}
FROM {{ source_table }}
{% for join_dict in join_dicts %}
    {%- set outer_loop = loop -%}
    {{ join_dict["join_type"] }} JOIN {{ join_dict["table_b"] }}
    {%- if join_dict["join_type"]|upper != 'CROSS' %}
    ON
    {%- for join_col1, join_col2 in join_dict["join_on"].items() -%}
        {{ " AND " if loop.index != 1 else "" }}
        {{ table_from_fqtn(source_table) if outer_loop.index == 1 else table_from_fqtn(join_dict["table_a"]) }}.{{ join_col1 }} = {{ table_from_fqtn(join_dict["table_b"]) }}.{{ join_col2 }}
    {% endfor %}
    {%- endif -%}
{%- endfor -%}