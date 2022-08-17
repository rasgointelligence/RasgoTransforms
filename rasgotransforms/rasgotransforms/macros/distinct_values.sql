{% from 'filter.sql' import get_filter_statement %}

{% macro get_distinct_vals(
    columns,
    target_metric,
    max_vals,
    source_table,
    filters
) %}
{% set filter_statement = get_filter_statement(filters) %}
{% set distinct_val_query %}
    select
        concat(
            {% for column in columns %}
            {{ column }}{{", '_', " if not loop.last}}
            {% endfor %}
        ) as dimensions,
        {{ target_metric.agg_method|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct ' in target_metric.agg_method|lower else ''}}{{ target_metric.column }}) as vals
    from {{ source_table }}
        {{ filter_statement }}
    group by 1
    order by vals desc
    limit {{ max_vals + 1}}
{% endset %}
{% set query_result = run_query(distinct_val_query) %}
{% set distinct_vals = [] %}
{% for val in query_result.itertuples() %}
{% set distinct_val = [] %}
{% for column in query_result.columns[:-1] %}
{% do distinct_val.append(val[column]) %}
{% if not loop.last %} {% do distinct_val.append("_") %} {% endif %}
{% endfor %}
{% do distinct_vals.append("_".join(distinct_val)) %}
{% endfor %}
{% if distinct_vals | length > max_vals %}
{% set distinct_vals = distinct_vals[:-1] + ["_OtherGroup"] %}
{% endif %}
{{ distinct_vals | to_json }}
{% endmacro %}

{% macro distinct_vals_from_query(
    columns,
    target_metric,
    max_vals,
    query,
    filters
) %}
{% set filter_statement = get_filter_statement(filters) %}
{% set distinct_val_query %}
    with distinct_vals_source_query as (
        {{ query|indent }}
    )
    select
        concat(
            {% for column in columns %}
            {{ column }}{{", '_', " if not loop.last}}
            {% endfor %}
        ) as dimensions,
        coalesce({{ target_metric.agg_method|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct ' in target_metric.agg_method|lower else ''}}{{ target_metric.column }}), 0) as vals
    from distinct_vals_source_query
        {{ filter_statement }}
    group by 1
    order by vals desc
    limit {{ max_vals + 1}}
{% endset %}
{% set query_result = run_query(distinct_val_query) %}
{% set distinct_vals = [] %}
{% for val in query_result.itertuples() %}
{% set distinct_val = [] %}
{% for column in query_result.columns[:-1] %}
{% do distinct_val.append(val[column]) %}
{% if not loop.last %} {% do distinct_val.append("_") %} {% endif %}
{% endfor %}
{% do distinct_vals.append("_".join(distinct_val)) %}
{% endfor %}
{% if distinct_vals | length > max_vals %}
{% set distinct_vals = distinct_vals[:-1] + ["_OtherGroup"] %}
{% endif %}
{{ distinct_vals | to_json }}
{% endmacro %}
