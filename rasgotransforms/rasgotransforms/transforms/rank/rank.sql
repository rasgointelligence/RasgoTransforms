{%- set untouched_cols = get_columns(source_table)|list|reject('in', rank_columns)|join(',') if overwrite_columns else "*" -%}

{%- set alias = alias if alias is defined else cleanse_name('RANK_' + '_'.join(rank_columns)) -%}

select
    {{ untouched_cols }},
    {%- if rank_type == 'dense' %}
    dense_rank() over (
    {% elif rank_type == 'percent' %}
    percent_rank() over (
    {% elif rank_type == 'unique' %} row_number() over ( {%- else -%} rank() over (
    {% endif %}
        {% if partition_by -%}
        partition by
            {% for col in partition_by -%}
            {{ col }}{{ ", " if not loop.last else " " }}
            {%- endfor %}
        {% endif -%}
        order by
            {% for col in rank_columns -%}
            {{ col }}
            {% if order %} {{ order }}{% endif %} {{ ", " if not loop.last else " " }}
            {%- endfor %}
    ) as {{ alias }}
from {{ source_table }}
{% if qualify_filter %} qualify {{ alias }} {{ qualify_filter }}{% endif %}
