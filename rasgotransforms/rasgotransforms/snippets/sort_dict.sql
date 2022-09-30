{% for column, direction in sort_dict.items() -%}
  {{ column }} {{ direction }}{%- if not loop.last %}, {% endif -%}
{%- endfor %}