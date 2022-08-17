{% from 'distinct_values.sql' import distinct_vals_from_query %}

{% macro combine_groups(query, keep_columns, dimensions, max_num_groups, target_metric) %}
    {% set distinct_vals = distinct_vals_from_query(
        columns=dimensions,
        target_metric=target_metric,
        max_vals=max_num_groups,
        query=query,
        filters=[]
    ) | from_json %}

    with combine_groups_source_query as (
        {{ query|indent }}
    ),
    combined_groups as (
        select
            {% for column in keep_columns %}
            {{ column }},
            {% endfor %}
            concat(
                {% for dimension in dimensions %}
                {{ dimension }}{{", '_', " if not loop.last}}
                {% endfor %}
            ) as combined_dimensions,
            case
                when combined_dimensions in (
                    {% for val in distinct_vals %}
                    '{{ val }}'{{',' if not loop.last else ''}}
                    {% endfor %}
                ) then combined_dimensions
                {% if 'None' in distinct_vals %}
                when combined_dimensions is null then 'None'
                {% endif %}
                else '_OtherGroup'
            end as dimensions
        from combine_groups_source_query
    )
    select
        {% for column in keep_columns %}
        {{ column }},
        {% endfor %}
        dimensions
    from combined_groups
{% endmacro %}
