select
    *,
    {% if type == 'ntile' %}
    ntile({{ bin_count }}) over (
        order by {{ column }}
    ) as {{ column }}_{{ bin_count }}_ntb
    {% elif type == 'equalwidth' %}
    width_bucket(
        {{ column }},
        (select min({{ column }}) from {{ source_table }}),
        (select max({{ column }}) from {{ source_table }}),
        {{ bin_count }}
    ) as {{ column }}_{{ bin_count }}_ewb
    {% else %}
    {{ raise_exception('You must select either "ntile" or "equalwidth" as your binning type') }}
    {% endif %}
from {{ source_table }}
