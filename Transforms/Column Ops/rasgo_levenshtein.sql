-- args: {{FeatureOne}}, {{FeatureTwo}}

-- SELECT *,
EDITDISTANCE({{FeatureOne}} , {{FeatureTwo}})
-- FROM {{source_table}}