def infer_columns(args, source_columns) -> dict:
    if 'include_cols' in args:
        return {k: v for k, v in source_columns.items() if k in args['include_cols']}
    else:
        return {k: v for k, v in source_columns.items() if k not in args['exclude_cols']}
