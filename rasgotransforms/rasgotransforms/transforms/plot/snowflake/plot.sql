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

{%- set row_count_query %}
select count(*) from {{ source_table }}
{% endset %}
{% set row_count_query_results = run_query(row_count_query) %}
{%- set row_count = row_count_query_results[row_count_query_results.columns[0]][0] -%}

{%- if num_buckets is not defined -%}
    {%- set bucket_count = 200 -%}
{%- else -%}
    {%- set bucket_count = num_buckets -%}
{%- endif -%}

{%- if row_count|int < bucket_count|int -%}
    {%- set bucket_count = row_count|int -%}
{%- endif -%}

{%- if group_by is defined and group_by -%}
    {%- set distinct_val_query -%}
        select distinct {{ group_by }}
        from {{ source_table }}
        limit 100
    {%- endset -%}
    {%- set results = run_query(distinct_val_query) -%}
    {%- set distinct_vals = results[results.columns[0]].to_list() -%}
    {%- if distinct_vals|length > 20-%}
        {{ raise_exception('The group by column has more than 20 distinct values. Please group by columns with less than 20 distinct values.') }}
    {%- endif -%}
{%- endif -%}

{# if the axis is continuous or a date, do a line chart #}
{%- if axis_type in ['date', 'numeric'] -%}
    WITH AXIS_RANGE AS (
    {# Use a user-defined axis column to calculate the min & max of the axis (and buckets on the axis) #}
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
        {# Assigns a bucket to each value of each column in users column list #}
        {# Row count of result set should match the row count of the raw table #}
        MIN_VAL
    ,MAX_VAL
    ,BUCKET_SIZE
    ,CAST({{ "DATE_PART(EPOCH_SECOND, " + x_axis +")" if axis_type == 'date' else x_axis }} AS FLOAT) AS COL_A_VAL
    ,WIDTH_BUCKET(COL_A_VAL, MIN_VAL, MAX_VAL, {{ bucket_count }}) AS COL_A_BUCKET
    {%- if group_by is defined and group_by %}
        {%- for col, aggs in metrics.items() %}
            {%- for distinct_val in distinct_vals %}
                ,CASE WHEN {{ group_by }} = '{{ distinct_val }}' THEN {{ col }} END AS {{ cleanse_name(distinct_val) }}_{{ col }}
            {%- endfor %}
        {%- endfor %}
    {%- else %}
        {%- for col, aggs in metrics.items() %}
            ,{{ col }}
        {%- endfor %}
    {%- endif %}

    FROM
        {{ source_table }}
        CROSS JOIN EDGES
        {%- if filters is defined and filters %}
            {% for filter_block in filters %}
            {%- set oloop = loop -%}
            {{ 'WHERE ' if oloop.first else ' AND ' }}
                {%- if filter_block is not mapping -%}
                    {{ filter_block }}
                {%- else -%}
                    {%- if filter_block['operator'] == 'CONTAINS' -%}
                        {{ filter_block['operator'] }}({{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }})
                    {%- else -%}
                        {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
                    {%- endif -%}
                {%- endif -%}
            {%- endfor -%}
        {%- endif -%}
    )
    {# Run final aggregates on the buckets #}
    SELECT
    {% if axis_type == 'date' -%}
        CAST((MIN_VAL+((COL_A_BUCKET-1)*BUCKET_SIZE)) AS DATETIME) AS {{ x_axis }}_MIN
        ,CAST((MIN_VAL+(COL_A_BUCKET*BUCKET_SIZE)) AS DATETIME) AS {{ x_axis }}_MAX
    {%- else -%}
        MIN_VAL+((COL_A_BUCKET-1)*BUCKET_SIZE) AS {{ x_axis }}_MIN
        ,MIN_VAL+(COL_A_BUCKET*BUCKET_SIZE) AS {{ x_axis }}_MAX
    {%- endif -%}
    {%- if group_by is defined and group_by %}
        {%- for col, aggs in metrics.items() %}
            {%- for agg in aggs %}
                {%- for distinct_val in distinct_vals %}
                    ,{{ agg }}({{ cleanse_name(distinct_val) }}_{{ col }}) AS {{ cleanse_name(distinct_val) }}_{{ agg }}_{{ col }}
                {%- endfor -%}
            {%- endfor -%}
        {%- endfor %}
    {%- else %}
        {%- for col, aggs in metrics.items() %}
            {%- for agg in aggs %}
                ,{{ agg }}({{ col }}) AS {{ agg }}_{{ col }}
            {%- endfor -%}
        {%- endfor %}
    {%- endif %}

    FROM BUCKETS
    WHERE {{ x_axis }}_MIN is not NULL
    GROUP BY 1, 2
    ORDER BY 1

{%- elif axis_type == 'categorical' -%}
{# if the axis is a categorical dimension, build a bar chart #}
    {%- if distinct_vals is defined and distinct_vals %}
        WITH TEMP AS (
            SELECT
            {{ x_axis }}
            {% for col, aggs in metrics.items() %}
                {% for distinct_val in distinct_vals %}
                    ,CASE WHEN {{ group_by }} = '{{ distinct_val }}' THEN {{ col }} END AS {{ cleanse_name(distinct_val) }}_{{ col }}
                {%- endfor %}
            {%- endfor %}
            FROM {{ source_table }}
        )
        SELECT
        {{ x_axis }}
        {% for col, aggs in metrics.items() %}
            {% for agg in aggs %}
                {% for distinct_val in distinct_vals %}
                    ,{{ agg }}({{ cleanse_name(distinct_val) }}_{{ col }}) AS {{ cleanse_name(distinct_val) }}_{{ agg }}_{{ col }}
                {%- endfor %}
            {%- endfor %}
        {%- endfor %}
        FROM TEMP
        GROUP BY {{ x_axis }}
        {{ ("ORDER BY " + x_axis + " " + x_axis_order) if x_axis_order else '' }}
    {%- else %}
        SELECT
        {{ x_axis }},

        {%- for col, aggs in metrics.items() %}
            {%- set outer_loop = loop -%}
            {%- for agg in aggs %}
                {{ agg }}({{ col }}) as {{ col + '_' + agg }}{{ '' if loop.last and outer_loop.last else ',' }}
            {%- endfor -%}
        {%- endfor %}
        FROM {{ source_table }}
        {%- if filters is defined and filters %}
            {% for filter_block in filters %}
            {%- set oloop = loop -%}
            {{ 'WHERE ' if oloop.first else ' AND ' }}
                {%- if filter_block is not mapping -%}
                    {{ filter_block }}
                {%- else -%}
                    {%- if filter_block['operator'] == 'CONTAINS' -%}
                        {{ filter_block['operator'] }}({{ filter_block['columnName'] }}, {{ filter_block['comparisonValue'] }})
                    {%- else -%}
                        {{ filter_block['columnName'] }} {{ filter_block['operator'] }} {{ filter_block['comparisonValue'] }}
                    {%- endif -%}
                {%- endif -%}
            {%- endfor -%}
        {%- endif %}
        GROUP BY {{ x_axis }}
        {{ ("ORDER BY " + x_axis + " " + x_axis_order) if x_axis_order else '' }}
    {% endif %}
{%- endif -%}
