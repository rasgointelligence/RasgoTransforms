with
    cte_condition as (
        select
            {{ date_col }} as dtm
            {% if group_cols -%},{% endif -%}
            {% if group_cols -%}
            {% for group_col in group_cols -%}
            {{ group_col }}{{ ", " if not loop.last else " " }}
            {%- endfor %}
            {% endif -%}
        from {{ source_table }}
        where
            {% if conditions -%}
            {% for condition in conditions -%}
            {{ condition }}{{ " AND " if not loop.last else " " }}
            {%- endfor %}
            {% endif -%}
            {% if conditions -%} and {% endif -%} {{ date_col }} is not null
    ),
    cte_lagged as (
        select
            dtm
            {% if group_cols -%},{% endif -%}
            {% if group_cols -%}
            {% for group_col in group_cols -%}
            {{ group_col }}{{ ", " if not loop.last else " " }}
            {%- endfor %}
            {% endif -%},
            lag(dtm) over (
                {% if group_cols -%}
                partition by
                {% endif -%}
                    {% if group_cols -%}
                    {% for group_col in group_cols -%}
                    {{ group_col }}{{ ", " if not loop.last else " " }}
                    {%- endfor %}
                    {% endif -%}
                order by dtm
            ) as previous_datetime,
            lead(dtm) over (
                {% if group_cols -%}
                partition by
                {% endif -%}
                    {% if group_cols -%}
                    {% for group_col in group_cols -%}
                    {{ group_col }}{{ ", " if not loop.last else " " }}
                    {%- endfor %}
                    {% endif -%}
                order by dtm
            ) as next_datetime,
            row_number() over (
                {% if group_cols -%}
                partition by
                {% endif -%}
                    {% if group_cols -%}
                    {% for group_col in group_cols -%}
                    {{ group_col }}{{ ", " if not loop.last else " " }}
                    {%- endfor %}
                    {% endif -%}
                order by cte_condition.dtm
            ) as island_location
        from cte_condition
    ),
    cte_island_start as (
        select
            row_number() over (
                {% if group_cols -%}
                partition by
                {% endif -%}
                    {% if group_cols -%}
                    {% for group_col in group_cols -%}
                    {{ group_col }}{{ ", " if not loop.last else " " }}
                    {%- endfor %}
                    {% endif -%}
                order by dtm
            ) as island_number
            {% if group_cols -%},{% endif -%}
            {% if group_cols -%}
            {% for group_col in group_cols -%}
            {{ group_col }}{{ ", " if not loop.last else " " }}
            {%- endfor %}
            {% endif -%},
            dtm as island_start_datetime,
            island_location as island_start_location
        from cte_lagged
        where
            (
                datediff({{ buffer_date_part }}, previous_datetime, dtm)
                > {{ buffer_size }}
                or cte_lagged.previous_datetime is null
            )
    ),
    cte_island_end as (
        select
            row_number() over (
                {% if group_cols -%}
                partition by
                {% endif -%}
                    {% if group_cols -%}
                    {% for group_col in group_cols -%}
                    {{ group_col }}{{ ", " if not loop.last else " " }}
                    {%- endfor %}
                    {% endif -%}
                order by dtm
            ) as island_number
            {% if group_cols -%},{% endif -%}
            {% if group_cols -%}
            {% for group_col in group_cols -%}
            {{ group_col }}{{ ", " if not loop.last else " " }}
            {%- endfor %}
            {% endif -%},
            dtm as island_end_datetime,
            island_location as island_end_location
        from cte_lagged
        where
            datediff({{ buffer_date_part }}, dtm, next_datetime) > {{ buffer_size }}
            or cte_lagged.next_datetime is null
    )
select
    {% if group_cols -%}
    {% for group_col in group_cols -%}
    cte_island_start.{{ group_col }}{{ ", " if not loop.last else " " }}
    {%- endfor %},
    {% endif -%}
    cte_island_start.island_start_datetime,
    cte_island_end.island_end_datetime,
    datediff(
        {{ buffer_date_part }},
        cte_island_start.island_start_datetime,
        cte_island_end.island_end_datetime
    ) as island_duration_{{ buffer_date_part }},
    (
        select count(*)
        from cte_lagged
        where
            cte_lagged.dtm between cte_island_start.island_start_datetime and
            cte_island_end.island_end_datetime
            {% if group_cols -%}
            and {% for group_col in group_cols -%}
            cte_lagged.{{ group_col }} = cte_island_start.{{ group_col }}
            and cte_lagged.{{ group_col }}
            = cte_island_start.{{ group_col }}{{ " AND " if not loop.last else " " }}
            {%- endfor %}
            {% endif -%}
    ) as island_row_count
from cte_island_start
inner join
    cte_island_end on cte_island_end.island_number = cte_island_start.island_number
    {% if group_cols -%}
    {% for group_col in group_cols %}
    and cte_island_start.{{ group_col }} = cte_island_end.{{ group_col }}
    {%- endfor %}
    {% endif -%}
