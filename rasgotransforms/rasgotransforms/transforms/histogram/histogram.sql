{%- if num_buckets is not defined -%} {%- set bucket_count = 200 -%}
{%- else -%} {%- set bucket_count = num_buckets -%}
{%- endif -%}

with
    counts as (
        select replace('{{ column }}', '"') as feature, col as val, count(1) as rec_ct
        from
            (
                select cast({{ column }} as float) as col
                from
                    {{ source_table }}
                    {%- if filters is defined and filters %}
                    {% for filter_block in filters %}
                    {%- set oloop = loop -%}
                    {{ 'WHERE ' if oloop.first else ' AND ' }}
                    {%- if filter_block is not mapping -%} {{ filter_block }}
                    {%- else -%}
                    {%- if filter_block['operator'] == 'CONTAINS' -%}
                    {{ filter_block['operator'] }} (
                        {{ filter_block['columnName'] }},
                        {{ filter_block['comparisonValue'] }}
                    )
                    {%- else -%}
                    {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
                    {%- endif -%}
                    {%- endif -%}
                    {%- endfor -%}
                    {%- endif -%}
            )
        where col is not null
        group by 2
    ),
    calcs as (select min(val) -1 min_val, max(val) + 1 max_val from counts),
    edges as (
        select
            min_val,
            max_val,
            (min_val - max_val) val_range,
            ((max_val - min_val) /{{ bucket_count }}) bucket_size
        from calcs
    ),
    freqs as (
        select
            feature,
            val,
            rec_ct,
            width_bucket(val, min_val, max_val, {{ bucket_count }}) as hist_bucket,
            min_val,
            max_val,
            bucket_size
        from counts
        cross join edges
    )
select
    min_val + ((hist_bucket -1) * bucket_size) as {{ column }}_min,
    min_val + (hist_bucket * bucket_size) as {{ column }}_max,
    sum(rec_ct) as record_count
from freqs
group by 1, 2
order by 1
