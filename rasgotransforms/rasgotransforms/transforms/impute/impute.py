def infer_columns(args, source_columns) -> dict:
    if 'flag_missing_vals' in args and args['flag_missing_vals']:
        for target_col, _ in args['imputations'].items():
            source_columns[f"{target_col}_missing_flag".upper()] = 'int'
    return source_columns
