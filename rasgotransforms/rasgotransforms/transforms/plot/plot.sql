{%- set axis_type_dict = get_columns(source_table) -%}
{%- set axis_type_response = axis_type_dict[x_axis].upper() -%}
{%- if 'DATE' in axis_type_response or 'TIME' in axis_type_response -%}
  {%- set axis_type = "date" -%}
{%- elif 'NUM' in axis_type_response or 'FLOAT' in axis_type_response or 'INT' in axis_type_response or 'DECIMAL' in axis_type_response or 'DOUBLE' in axis_type_response or 'REAL' in axis_type_response -%}
    {%- set axis_type = "numeric" -%}
{%- elif 'BINARY' in axis_type_response or 'TEXT' in axis_type_response or 'BOOLEAN' in axis_type_response or 'CHAR' in axis_type_response or 'STRING' in axis_type_response or 'VARBINARY' in axis_type_response -%}
    {%- set axis_type = "categorical" -%}
{%- else -%}
    {{ raise_exception('The column selected as an axis is not categorical, numeric, or datetime. Please choose an axis that is any of these data types and recreate the transform.') }}
{%- endif -%}

{%- if num_buckets is not defined -%}
    {%- set bucket_count = 200 -%}
{%- else -%}
    {%- set bucket_count = num_buckets -%}
{%- endif -%}

-- if the axis is continuous or a date, do a line chart
{% if axis_type in ['date', 'numeric'] -%}
    WITH AXIS_RANGE AS (
    -- Use a user-defined axis column to calculate the min & max of the axis (and buckets on the axis)
    SELECT
        {% if axis_type == 'date' -%}
            MIN(DATE_PART(EPOCH_SECOND, {{ x_axis }}))-1 AS MIN_VAL
            ,MAX(DATE_PART(EPOCH_SECOND, {{ x_axis }}))+1 AS MAX_VAL
        {% else %}
            MIN({{ x_axis }})-1 AS MIN_VAL
            ,MAX({{ x_axis }})+1 AS MAX_VAL
        {%- endif %}
    FROM
        {{ source_table }}
    WHERE
        {{ x_axis }} IS NOT NULL
    ), EDGES AS (
    SELECT MIN_VAL, MAX_VAL, (MIN_VAL-MAX_VAL) VAL_RANGE, ((MAX_VAL-MIN_VAL)/{{ bucket_count }}) BUCKET_SIZE FROM AXIS_RANGE
    ),
    BUCKETS AS (
    SELECT
        -- Assigns a bucket to each value of each column in user's column list
        -- Row count of result set should match the row count of the raw table
        MIN_VAL
    ,MAX_VAL
    ,BUCKET_SIZE
    ,{{ "DATE_PART(EPOCH_SECOND, " + x_axis +")" if axis_type == 'date' else x_axis }}::float AS COL_A_VAL
    ,WIDTH_BUCKET(COL_A_VAL, MIN_VAL, MAX_VAL, {{ bucket_count }}) AS COL_A_BUCKET
    {%- for col, aggs in metrics.items() %}
    ,{{ col }}
    {%- endfor %}

    FROM
        {{ source_table }}
        {% if filter_statements is iterable -%}
            {%- for filter_statement in filter_statements %}
        {{ 'WHERE' if loop.first else 'AND' }} {{ filter_statement }}
            {%- endfor -%}
        {%- endif %}

        CROSS JOIN EDGES
    )
    -- Run final aggregates on the buckets
    SELECT
    {% if axis_type == 'date' -%}
        (MIN_VAL+((COL_A_BUCKET-1)*BUCKET_SIZE))::DATETIME AS {{ x_axis }}_MIN
        ,(MIN_VAL+(COL_A_BUCKET*BUCKET_SIZE))::DATETIME AS {{ x_axis }}_MAX
    {%- else -%}
        MIN_VAL+((COL_A_BUCKET-1)*BUCKET_SIZE) AS {{ x_axis }}_MIN
        ,MIN_VAL+(COL_A_BUCKET*BUCKET_SIZE) AS {{ x_axis }}_MAX
    {%- endif -%}
    {%- for col, aggs in metrics.items() %}
        {%- for agg in aggs %}
            ,{{ agg }}({{ col }}) AS {{ agg }}_{{ col }}
        {%- endfor -%}
    {%- endfor %}

    FROM BUCKETS
    WHERE {{ x_axis }}_MIN is not NULL
    {%- if filter_statements is iterable -%}
        {%- for filter_statement in filter_statements %}
            AND {{ filter_statement }}
        {%- endfor -%}
    {%- endif %}
    GROUP BY 1, 2
    ORDER BY 1

{%- elif axis_type == 'categorical' -%}
-- if the axis is a categorical dimension, build a bar chart
    SELECT
    {{ x_axis }},

    {%- for col, aggs in metrics.items() %}
        {%- set outer_loop = loop -%}
        {%- for agg in aggs %}
            {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
        {%- endfor -%}
    {%- endfor %}
    FROM {{ source_table }}
    {% if filter_statements is iterable -%}
        {%- for filter_statement in filter_statements %}
            {{ 'WHERE' if loop.first else 'AND' }} {{ filter_statement }}
        {%- endfor -%}
    {%- endif %}
    GROUP BY {{ x_axis }}
    {{ "ORDER BY " + x_axis + " " + order_direction if order_direction else '' }}
{%- endif -%}
