{%- set source_col_names = get_columns(source_table) -%}
with
    outliers as (
        {%- if method == "iqr" %}
        with
            iqr_vals as (
                select
                    {%- for col in target_columns %}
                    percentile_cont(0.25) within group (
                        order by {{ col }}
                    ) as q1_{{ col }},
                    percentile_cont(0.5) within group (
                        order by {{ col }}
                    ) as median_{{ col }},
                    percentile_cont(0.75) within group (
                        order by {{ col }}
                    ) as q3_{{ col }}{{ ", " if not loop.last else " " }}
                    {%- endfor %}
                from {{ source_table }}
            )
        select
            *,
            case
                {%- for col in target_columns %}
                when
                    {{ col }} > median_{{ col }} + ((q3_{{ col }} - q1_{{ col }}) * 1.5)
                then true
                when
                    {{ col }} < median_{{ col }} - ((q3_{{ col }} - q1_{{ col }}) * 1.5)
                then true
                {%- endfor %}
                else false
            end as outlier
        from {{ source_table }}, iqr_vals

        {%- elif method == "threshold" %}
        select
            *,
            case
                {%- for col in target_columns %}
                when {{ col }} > {{ max_threshold }}
                then true
                when {{ col }} < {{ min_threshold }}
                then true
                {%- endfor %}
                else false
            end as outlier
        from {{ source_table }}
        {%- else %}
        {%- if max_zscore is not defined -%}{%- set max_zscore = 2 -%}
        {%- endif %}
        with
            tbl_mean_std as (
                select
                    {%- for col in target_columns %}
                    avg({{ col }}) mean_{{ col }},
                    stddev(
                        {{ col }}
                    ) stddev_{{ col }}{{ ", " if not loop.last else " " }}
                    {%- endfor %}
                from {{ source_table }}
            )
        select
            *,
            {%- for col in target_columns %}
            ({{ col }} - mean_{{ col }}) / stddev_{{ col }} as zscore_{{ col }},
            {%- endfor %}
            case
                {%- for col in target_columns %}
                when abs(zscore_{{ col }}) > {{ max_zscore }} then true
                {%- endfor %}
                else false
            end as outlier
        from {{ source_table }}, tbl_mean_std
        {%- endif %}
    )
select
    {% if not drop -%} outlier, {%- endif %}
    {% for col in source_col_names -%}
    {{ col }}{{ ", " if not loop.last else " " }}
    {%- endfor %}
from outliers
{% if drop -%} where not outlier {%- endif -%}
