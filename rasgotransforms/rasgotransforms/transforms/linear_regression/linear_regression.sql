select
    {{ group_by | join(', ') }}{{ ', ' if group_by else '' }}
    regr_slope({{ y }}, {{ x }}) slope,
    regr_intercept({{ y }}, {{ x }}) intercept,
    regr_r2({{ y }}, {{ x }}) r2,
    concat('Y = ', slope, '*X + ', intercept) as formula
from {{ source_table }} {{ 'GROUP BY ' if group_by else '' }}{{ group_by | join(', ') }}
