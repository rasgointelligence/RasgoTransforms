{# Placeholder code. Will be replaced by user supplied template #}
{% if sql %}
{{ sql }}
{% else %}
SELECT * FROM {{ source_table }}
{% endif %}
{{ raise_exception('Placeholder code must be replaced by user supplied template') }}