{%- if overwrite_columns == true -%}

    {%- set source_columns = get_columns(source_table) -%}
    {%- set untouched_cols = source_columns | reject('in', casts) -%}

    SELECT {% for col in untouched_cols %}{{ col }},{% endfor %}
    {%- for target_col, type in casts.items() %}
        {%- if type|lower == 'float' %}
            CAST({{target_col}} AS FLOAT64) AS {{target_col}}{{", " if not loop.last else ""}}f
        {%- elif type|lower == 'number' %}
            CAST({{target_col}} AS NUMERIC) AS {{target_col}}{{", " if not loop.last else ""}}
        {%- else %}
            CAST({{target_col}} AS {{type}}) AS {{target_col}}{{", " if not loop.last else ""}}
        {%- endif %}
    {%- endfor %}
    FROM {{ source_table }}

{%- else -%}

    SELECT *
    {%- for target_col, type in casts.items() %}
        {%- if type|lower == 'float' %}
            ,CAST({{target_col}} AS FLOAT64) AS {{cleanse_name(target_col)+'_'+cleanse_name(type)}}
        {%- elif type|lower == 'number' %}
            ,CAST({{target_col}} AS NUMERIC) AS {{cleanse_name(target_col)+'_'+cleanse_name(type)}}
        {%- else %}
            ,CAST({{target_col}} AS {{type}}) AS {{cleanse_name(target_col)+'_'+cleanse_name(type)}}
        {%- endif %}
    {%- endfor %}
    FROM {{ source_table }}

{%- endif -%}
