-- Args: {{bucket_count}}, {{col_to_bucket}}

SELECT *,
  width_bucket({{col_to_bucket}}, MIN({{col_to_bucket}}), MAX({{col_to_bucket}}), {{bucket_count}}) AS {{col_to_bucket}}_{{bucket_count}}_BUCKETS
FROM {{ source_table }}
