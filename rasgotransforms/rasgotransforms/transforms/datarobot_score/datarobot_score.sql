SELECT {{ include_cols|join(',') }},

{%- if num_explains is defined and threshold_low is defined and threshold_high is defined -%}
    S:score AS PREDICTION
    {%- set function_call = '(OBJECT_CONSTRUCT_KEEP_NULL(*),' ~ num_explains ~ ',' ~ threshold_low ~ ',' ~ threshold_high ~ ')' %}
    {% for i in range(num_explains) -%}
    ,CONCAT(S:explanations[{{ i }}].featureName, '=', S:explanations[{{ i }}].featureValue, ' (', S:explanations[{{ i }}].strength, ')') AS TOP{{ i+1 }}_INFLUENCING_FACTOR
    {% endfor -%}
{%- else -%}
    S AS PREDICTION
    {% set function_call = '(OBJECT_CONSTRUCT_KEEP_NULL(*))' %}
{%- endif %}
FROM (
    SELECT *,
    {{ function_name }}{{ function_call }} AS S
    FROM {{ source_table }} )