{#
Jinja Macro to generate a query that would get all
the columns in a table by fqtn
#}
{%- macro get_source_col_names(source_table_fqtn=None) -%}
    select * from {{ source_table_fqtn }} limit 0
{%- endmacro -%}
{%- set col_names_source_df = run_query(get_source_col_names(source_table_fqtn=source_table)) -%}
{%- set source_col_names = col_names_source_df.columns.to_list() -%}
with outliers as (
    {%- if method == "iqr" %}
    with iqr_vals as (
        select
            {%- for col in target_columns %}
            percentile_cont(0.25) within group (order by {{ col }}) as Q1_{{ col }},
            percentile_cont(0.5) within group (order by {{ col }}) as MEDIAN_{{ col }},
            percentile_cont(0.75) within group (order by {{ col }}) as Q3_{{ col }}{{ ", " if not loop.last else " " }}
            {%- endfor %}
        from {{ source_table }}
    ) select *,
           case
               {%- for col in target_columns %}
               when {{ col }} > MEDIAN_{{ col }} + ((Q3_{{ col }} - Q1_{{ col }}) * 1.5) then true
               when {{ col }} < MEDIAN_{{ col }} - ((Q3_{{ col }} - Q1_{{ col }}) * 1.5) then true
               {%- endfor %}
               else false
          end as OUTLIER
    from {{ source_table }}, iqr_vals

    {%- elif method == "threshold" %}
    select *,
           case
               {%- for col in target_columns %}
               when {{ col }} > {{ max_threshold }} then true
               when {{ col }} < {{ min_threshold }} then true
               {%- endfor %}
               else false
           end as OUTLIER
    from {{ source_table }}
    {%- else %}
        {%- if max_zscore is not defined -%}
        {%- set max_zscore = 2 -%}
        {%- endif %}
    with tbl_mean_std as (
        select
               {%- for col in target_columns %}
               avg({{ col }}) MEAN_{{ col }},
               stddev({{ col }}) STDDEV_{{ col }}{{ ", " if not loop.last else " " }}
               {%- endfor %}
        from {{ source_table }}
    ) select *,
            {%- for col in target_columns %}
            ({{col}} - MEAN_{{col}}) / STDDEV_{{ col }}  as ZSCORE_{{ col }},
            {%- endfor %}
            case
                {%- for col in target_columns %}
                when abs(ZSCORE_{{ col }}) > {{ max_zscore }} then TRUE
                {%- endfor %}
                else FALSE
            end as OUTLIER
    from {{ source_table }}, tbl_mean_std
    {%- endif %}
) select
    {% if not drop -%}
    OUTLIER,
    {%- endif %}
    {% for col in source_col_names -%}
    {{ col }}{{ ", " if not loop.last else " " }}
    {%- endfor %}
  from outliers
{% if drop -%}
    where not OUTLIER
{%- endif -%}
