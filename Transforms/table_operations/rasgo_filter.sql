{# args: {{filter_col}}, {{filter_val}} #}

SELECT * FROM {{ source_table }} WHERE {{filter_col}} = {{filter_val}}