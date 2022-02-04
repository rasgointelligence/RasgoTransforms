SELECT
 *,
{% if rank_type == 'dense' %} DENSE_RANK() OVER(
{% elif rank_type == 'percent' %} PERCENT_RANK() OVER(
{% elif rank_type == 'unique' %} ROW_NUMBER() OVER(
{% else %} RANK() OVER(
{% endif %}
{% if partition_by %} PARTITION BY
  {% for col in partition_by -%}{{col}}{{ ", " if not loop.last else " " }}{%- endfor %}
{% endif %}
 ORDER BY
  {% for col in rank_columns -%}{{col}}{{ ", " if not loop.last else " " }}{%- endfor %}
 {% if order %}{{ order }}{% endif %}
) AS RANK__{%- for col in rank_columns %}{{cleanse_name(col)}}{%- endfor %}
FROM {{ source_table }}
{% if qualify_filter %} QUALIFY RANK__{%- for col in rank_columns %}{{cleanse_name(col)}}{%- endfor %} {{ qualify_filter }}
{% endif %}
