{%- set untouched_cols = get_columns(source_table)|list|reject('in', rank_columns)|join(',') if overwrite_columns else "*" -%}

{%- set alias = alias if alias is defined else cleanse_name('RANK_' + '_'.join(rank_columns)) -%}

SELECT {{ untouched_cols }},
{%- if rank_type == 'dense' %}
  DENSE_RANK() OVER(
{% elif rank_type == 'percent' %}
  PERCENT_RANK() OVER(
{% elif rank_type == 'unique' %}
  ROW_NUMBER() OVER(
{%- else -%}
  RANK() OVER(
{% endif %}
    {% if partition_by -%}
    PARTITION BY {% for col in partition_by -%}{{col}}{{ ", " if not loop.last else " " }}{%- endfor %}
    {% endif -%}
    ORDER BY {% for col in rank_columns -%}{{col}}{% if order %} {{ order }}{% endif %}{{ ", " if not loop.last else " " }}{%- endfor %}
  ) AS {{ alias }}
FROM {{ source_table }}
{% if qualify_filter %}QUALIFY {{ alias }} {{ qualify_filter }}{% endif %}
