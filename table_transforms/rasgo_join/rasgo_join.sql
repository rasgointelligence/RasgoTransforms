SELECT t1.*, t2.* 
FROM {{ source_table }} as t1
LEFT JOIN {{ rasgo_source_ref(join_table_id) }} as t2
ON 
{%- for s_col in source_columns -%}
    {{ ' AND' if not loop.first else ''}} t1.{{ s_col }} = t2.{{ joined_colums[loop.index0] }}
{%- endfor -%}