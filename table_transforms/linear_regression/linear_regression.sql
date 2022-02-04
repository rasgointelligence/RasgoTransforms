SELECT {{ group_by | join(', ') }}{{ ', ' if group_by else ''}}
  REGR_SLOPE({{y}}, {{x}}) Slope,
  REGR_INTERCEPT({{y}}, {{x}}) Intercept,
  REGR_R2({{y}}, {{x}}) R2, 
  CONCAT('Y = ',Slope,'*X + ',Intercept) as Formula
FROM {{ source_table }}
{{ 'GROUP BY ' if group_by else ''}}{{ group_by | join(', ') }}