select
    {{ include_cols|join(',') }},

    {%- if num_explains is defined and threshold_low is defined and threshold_high is defined -%}
    s:score as prediction
    {%- set function_call = '(OBJECT_CONSTRUCT_KEEP_NULL(*),' ~ num_explains ~ ',' ~ threshold_low ~ ',' ~ threshold_high ~ ')' %}
    {% for i in range(num_explains) -%}
    ,
    concat(
        s:explanations[{{ i }}].featurename,
        '=',
        s:explanations[{{ i }}].featurevalue,
        ' (',
        s:explanations[{{ i }}].strength,
        ')'
    ) as top{{ i+1 }}_influencing_factor
    {% endfor -%}
    {%- else -%}
    s as prediction {% set function_call = '(OBJECT_CONSTRUCT_KEEP_NULL(*))' %}
    {%- endif %}
from (select *, {{ function_name }}{{ function_call }} as s from {{ source_table }})
