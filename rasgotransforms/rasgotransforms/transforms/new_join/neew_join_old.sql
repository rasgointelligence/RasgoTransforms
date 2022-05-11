{#
Jinja Macro to generate a query that would get all 
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn=None) -%}
    select * from {{ source_table_fqtn }} limit 0
{%- endmacro -%}

{#
Raise any exptions on badly formed input. Check
  1. `prefix` supplied for each Join Dict
  2. Others....
#}
{%- for join_dict in join_dicts  -%}
    {%- if not join_dict["join_prefix"] -%}
        {{ raise_exception("Join Dict " ~ loop.index ~ " is missing required param `prefix`") }}
    {%- endif -%}
{%- endfor -%}


{#
Get all the column names for each table in the supplied `join_dicts` args

Store in dict `table_col_names` keyed by FQTN
#}
{%- set table_col_names = {
    "source_table": run_query(get_source_col_names(source_table_fqtn=source_table))
    } 
-%}
{%- for join_dict in join_dicts  -%}
    {%- set _x = table_col_names.__setitem__(
        join_dict["join_table"], run_query(get_source_col_names(source_table_fqtn=join_dict["join_table"]))
    ) 
  -%}
{%- endfor -%}

{# Macros to get the columns name select for each join #}
{%- macro get_columns_in_join(join_cols1, join_cols2, prefixes, loop_index) -%}
    {%- for join_col1 in join_cols1  -%}
    t1.{{ join_col1 }},
    {%- endfor -%}
{%- endmacro -%}

{# Macros to get the base table of the join #}
{%- macro get_base_table(loop_index) -%}
    {% if loop_index == 1 -%}{{ source_table }}{% else %}join_{{ loop_index - 1}}{% endif %}
{%- endmacro -%}

{# Create One CTE for Each Join #}
{%- for join_dict in join_dicts  -%}
{% if loop.index != 1 -%},
{% else %}WITH {% endif %}join_{{ loop.index }} as (
    SELECT *
    FROM {{get_base_table(loop.index)}} as t1
    {{ join_dict["join_type"] }} JOIN {{ join_dict["join_table"] }} as t2
    ON {% for join_col1, join_col2 in join_dict["join_on"].items() %}{% if loop.index != 1 %} AND {% endif %}t1.{{ join_col1 }} = t2.{{ join_col2 }}{%- endfor %}
)
{%- endfor %}
SELECT * FROM join_{{ join_dicts | length }}
