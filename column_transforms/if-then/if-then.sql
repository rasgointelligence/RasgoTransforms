SELECT 
*,
CASE
{%- for condition in conditions %} 
    {{"WHEN " + condition[0] }} THEN {{ condition[1] }} {% endfor %}
    ELSE {{ default }}
END AS {{ cleanse_name(alias) }}
FROM {{ source_table }}
