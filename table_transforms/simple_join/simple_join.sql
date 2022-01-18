SELECT *
FROM
{{ source_table }}
{{ join_type | upper }} JOIN
{{ join_table }}
USING( {{join_columns | join(", ")}} )