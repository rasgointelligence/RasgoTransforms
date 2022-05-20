# INT_AGGREGATIONS = [
#     'AVG', 'CORR', 'COUNT',
# ]


def infer_columns(args, source_columns) -> dict:
    out_cols = {}
    for col in args['group_by']:
        out_cols[col] = source_columns[col.upper()]
    for col in args['aggregations'].keys():
        for agg in args['aggregations'][col]:
            out_cols[f'{col}_{agg}'] = 'NUMERIC'
    return out_cols
