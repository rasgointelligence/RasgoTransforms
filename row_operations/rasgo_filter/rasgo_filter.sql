SELECT * FROM {{source_table}}
{%- macro quote_if_string(var) -%}
    {%- set quote = "'" if var is string else '' -%}
    {{ quote }}{{ var }}{{ quote }}
{%- endmacro -%}

{%- for filter_col, col_filter in filter_dict.items() %}
    {%- set filter_type, filter_val = col_filter %}
{{ 'WHERE' if loop.first else 'AND' }} {{'"'}}{{filter_col}}{{'"'}} {{filter_type}} {{quote_if_string(filter_val)}}
{%- endfor -%}