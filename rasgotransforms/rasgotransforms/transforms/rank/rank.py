def infer_columns(args, source_columns) -> dict:
    if 'overwrite_columns' in args and args['overwrite_columns']:
        out_columns = {k: v for k, v in source_columns.items() if k not in args['rank_columns']}
    else:
        out_columns = source_columns.copy()
    out_columns[args['alias']] = 'integer'
    return out_columns
