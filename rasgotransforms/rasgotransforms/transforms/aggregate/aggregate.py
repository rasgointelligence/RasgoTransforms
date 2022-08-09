NUMERIC_TYPES = [
    'int',
    'integer',
    'bigint',
    'smallint',
    'number',
    'numeric',
    'float',
    'float4',
    'float8',
    'decimal',
    'double precision',
    'real',
]


def infer_columns(args, source_columns) -> dict:
    args = args.copy()
    out_cols = {}
    for col in args['group_by']:
        out_cols[col] = source_columns[col.upper()]
    if 'numeric columns' in args['aggregations'].keys():
        for column, column_type in source_columns.items():
            if column not in args['aggregations'].keys() and column_type.lower() in NUMERIC_TYPES:
                args['aggregations'].setdefault(column, []).extend(args['aggregations']['numeric columns'])
        args['aggregations'].pop('numeric columns')
    if 'nonnumeric columns' in args['aggregations'].keys():
        for column, column_type in source_columns.items():
            if column not in args['aggregations'].keys() and column_type.lower() not in NUMERIC_TYPES:
                args['aggregations'].setdefault(column, []).extend(args['aggregations']['nonnumeric columns'])
        args['aggregations'].pop('nonnumeric columns')
    for col in args['aggregations'].keys():
        for agg in args['aggregations'][col]:
            agg = agg.replace(' ', '')
            out_cols[f'{col}_{agg}'] = 'NUMERIC'
    return out_cols
