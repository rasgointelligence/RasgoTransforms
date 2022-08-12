select
    *,
    {%- if type == 'ntile' %}
    ntile({{ bin_count }}) over (
        order by {{ column }}
    ) as {{ column }}_{{ bin_count }}_ntb
    {%- elif type == 'equalwidth' %}
    range_bucket(
        {{ column }},
        generate_array(
            (select min({{ column }}) from {{ source_table }}),
            (select max({{ column }}) from {{ source_table }}),
            (
                select (max({{ column }}) - min({{ column }})) / 20
                from {{ source_table }}
            )
        )
    ) as {{ column }}_{{ bin_count }}_ewb
    {%- else %}
    {{ raise_exception('You must select either "ntile" or "equalwidth" as your binning type') }}
    {%- endif %}
from {{ source_table }}
