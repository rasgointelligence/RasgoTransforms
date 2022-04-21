{% if method == "iqr" %}

with iqr_vals as (
  select      percentile_cont(0.25) within group (order by {{ target_column }}) as Q1_{{ target_column }},
              percentile_cont(0.5) within group (order by {{ target_column }}) as MEDIAN_{{ target_column }},
              percentile_cont(0.75) within group (order by {{ target_column }}) as Q3_{{ target_column }}
  from        {{ source_table }}
) select *,
    case
        when {{ target_column }} > MEDIAN_{{ target_column }} + ((Q3_{{ target_column }} - Q1_{{ target_column }}) * 1.5) then true
        when {{ target_column }} < MEDIAN_{{ target_column }} - ((Q3_{{ target_column }} - Q1_{{ target_column }}) * 1.5) then true
        else false
    end as OUTLIER_{{ target_column }}
from {{ source_table }}, iqr_vals

{% elif method == "threshold" %}

select *,
    case
        when {{ target_column }} > {{ max_threshold }} then true
        when {{ target_column }} < {{ min_threshold }} then true
        else false
    end as OUTLIER_{{ target_column }}
from {{ source_table }}

{% else %}

{%- if max_zscore is not defined -%}
{%- set max_zscore = 2 -%}
{%- endif -%}

with tbl_mean_std as (
  select avg({{ target_column }}) MEAN_{{ target_column }}, stddev({{ target_column }}) STDDEV_{{ target_column }} 
  from {{ source_table }}
)
select *, 
    ({{ target_column }} - MEAN_{{ target_column }}) / STDDEV_{{ target_column }}  as ZSCORE_{{ target_column }},
    case
        when ZSCORE_{{ target_column }} > abs({{ max_zscore }}) then TRUE
        else FALSE
    end as OUTLIER_{{ target_column }}
from {{ source_table }}, tbl_mean_std;

{% endif %}


