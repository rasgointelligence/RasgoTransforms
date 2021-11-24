SELECT *
FROM
{{ source_table }}
{{ join_type + ' ' if join_type else '' | upper }}JOIN
{{ rasgo_source_ref(join_table) }}
USING( {{join_columns | join(", ")}} )