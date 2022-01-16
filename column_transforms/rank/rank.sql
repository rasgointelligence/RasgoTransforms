SELECT
*
{% if rank_type = 'dense' %}
  , DENSE_RANK() OVER(
{% elif rank_type = 'percent' %}
  , PERCENT_RANK() OVER(
{% elif rank_type = 'unique' %}
  , ROW_NUMBER() OVER(
{% else %}
  , RANK() OVER(
{% endif %}
{% if partition_by %}
 PARTITON BY partition_by
{% endif %}
 ORDER BY rank_columns
{% if order %}
 order
{% endif %}
) AS RANK_{{ cleanse_name(rank_columns) }}

FROM {{ source_table }}

{% if qualify_filter %}
QUALIFY RANK_{{ cleanse_name(rank_columns) }} qualify_filter
{% endif %}
