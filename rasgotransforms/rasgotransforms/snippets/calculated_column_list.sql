{%- for col_dict in calculated_columns %}
    {%- if 'alias' in col_dict -%}
    , {{ col_dict['calculated_column'] }} as {{ cleanse_name(col_dict['alias']) }}
    {%- else -%}
    , {{ col_dict['calculated_column'] }}
    {%- endif %}
{%- endfor %}